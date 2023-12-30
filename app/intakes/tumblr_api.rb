require './config/environment/'
require 'sidekiq-scheduler'
require 'json'

class TumblrApi  
  include Sidekiq::Job
  def perform()
    cnt_time_start = Time.now

    client = Tumblr::Client.new({
      :consumer_key => Rails.application.credentials.tumblr[:consumer_key_0],
      :consumer_secret => Rails.application.credentials.tumblr[:consumer_secret_0],
      :oauth_token => Rails.application.credentials.tumblr[:oauth_token_0],
      :oauth_token_secret => Rails.application.credentials.tumblr[:oauth_token_secret_0]
    })

    catch :api_limit_reached do
      # analyze events to intake, resume, or initialize account
      # updates dead events to resume
      # event exists, detects is in progress or needs resume
      Event.all.each do |e|
        cnt_time_cur = Time.now
        cnt_elapsed = cnt_time_cur - e.event_time.to_time 
        puts(e.info + ' dead? ' + cnt_elapsed.to_s)
        if cnt_elapsed > e.duration_limit
          puts(e.info + ' IS DEAD, setting to resume')
          e.update_attribute(:status, 'resume')
        end
      end
      @subsets = SrcUrlSubset.where(src_url_id:  SrcUrl.where(name: 'tumblr')[0].id)
      @todo = []
      @todoCheck = @subsets.filter { |s| s.time_last_scraped_completely == nil }
      @todoCheck.each do |s|
        if !Event.exists?(info: s.url)
          @todo << s
        elsif Event.where(info: s.url)[0].status == 'resume'
          @todo << s
        end
      end
      if @todo.length == 0 
        @todo = @subsets.filter { |s| s.time_last_scraped_completely != nil }
      else
        @todo.each do | new_s |
          if !Event.exists?(info: new_s.url)
            @event = Event.create(
              event_time: DateTime.now(),
              info: new_s.url,
              duration_limit: 40
            )
            puts new_s.url.split('/').last + ': initiallizing'
          else
            puts new_s.url.split('/').last + ': resuming initialization'
          end
        end
      end

      # cycles through approved accounts
      # cycles tokens if api limited
      # updates event if initializing 
      cnt_requests = 0
      @todo.each do | src_user |
        user = src_user.url.split('/').last
        cnt_post_offset = 0
        cnt_total_posts = -1 
        cnt_searched_posts = 0

        if Event.exists?(info: src_user.url)
          if(Event.where(info: src_user.url)[0].status == 'resume')
            cnt_post_offset = Integer(Event.where(info: src_user.url)[0].busy_objects, exception: false)
            cnt_searched_posts = cnt_searched_posts + cnt_post_offset
            Event.where(info: src_user.url)[0].update_attribute(:status, 'in progress')
          end
        end
        catch :cycle_posts do
          while cnt_post_offset <= cnt_total_posts || cnt_total_posts == -1
            api_response = client.posts (user + '.tumblr.com'), :limit => 50, :offset => cnt_post_offset, :notes_info => true, :reblog_info => true
            json = JSON.parse(api_response.to_json)
            if json.dig('status') == 429
              puts 'switching client tokens'
              client = Tumblr::Client.new({
                :consumer_key => Rails.application.credentials.tumblr[:consumer_key_1],
                :consumer_secret => Rails.application.credentials.tumblr[:consumer_secret_1],
                :oauth_token => Rails.application.credentials.tumblr[:oauth_token_1],
                :oauth_token_secret => Rails.application.credentials.tumblr[:oauth_token_secret_1]
              })
              api_response = client.posts (user + '.tumblr.com'), :limit => 50, :offset => cnt_post_offset, :notes_info => true, :reblog_info => true
              json = JSON.parse(api_response.to_json)
              if json.dig('status') == 429
                puts('all clients api limited')
                throw :api_limit_reached
              end
            end

            cnt_requests = cnt_requests + 1
            cnt_total_posts = json.dig('blog', 'total_posts')
            cnt_time_cur = Time.now
            cnt_elapsed = cnt_time_cur - cnt_time_start
            puts('t:' + (Time.at(cnt_elapsed).utc.strftime "%H:%M:%S") + ' ' + user + ' (' + cnt_requests.to_s + ') ' + cnt_searched_posts.to_s + '/' + cnt_total_posts.to_s)
            
            # cycles posts in api response
            json.dig('posts').each do |post|
              src_user = SrcUrlSubset.find(src_user.id)
              cnt_searched_posts = cnt_searched_posts + 1
              
              author = nil 
              src_url_subset_assigned_id = post.dig("id")
              time_posted = DateTime.parse(post.dig("date"))
              url = post.dig("post_url")
              description = ''
              hash_tags = []
              likes = []
              reblogs = []
              signed_url = []
              signed_url_s = []

              # is up to date check
              if src_user.time_last_entry != nil && src_user.time_last_scraped_completely != nil && cnt_post_offset > 0
                if time_posted > src_user.time_last_entry
                  SrcUrlSubset.find(src_user.id).update_attribute(:time_last_entry, time_posted)
                else
                  puts('account is up to date')
                  throw :cycle_posts
                end
              end
              # is latest post check
              if src_user.time_last_entry == nil
                SrcUrlSubset.find(src_user.id).update_attribute(:time_last_entry, time_posted)
              elsif time_posted > src_user.time_last_entry
                SrcUrlSubset.find(src_user.id).update_attribute(:time_last_entry, time_posted)
              end
              # is complete check
              if cnt_searched_posts == cnt_total_posts || (json.dig('posts').length < 50 && json.dig('posts').last == post)
                SrcUrlSubset.find(src_user.id).update_attribute(:time_last_scraped_completely, DateTime.now()) 
                Event.where(info: src_user.url).delete_all
                puts 'initialized'
              end
              if !Kernal.exists?(src_url_subset_assigned_id: src_url_subset_assigned_id)
                # image collect
                if !post.dig('photos').nil?
                  post.dig('photos').each do |photo|
                    index = photo.dig('alt_sizes').length - 3 > -1 ? post.dig('photos', 0, 'alt_sizes').length - 3 : 0
                    signed_url_s << photo.dig('alt_sizes', index, 'url')
                    signed_url << photo.dig('alt_sizes', 0, 'url')
                  end
                elsif !post.dig("question").nil? 
                  if post.dig("question").include? "srcset=\""
                    post.dig("question").split("srcset=\"").drop(1).each do |set|
                      img_src = set.split("\"")[0].scan(/\bhttps?:\/\/[^\s]+\.(?:jpg|gif|png|pnj|gifv|webp)\b/)
                      img_src_index = img_src.length > 2 ? 2 : 0
                      signed_url << img_src.last 
                      signed_url_s << img_src[img_src_index]
                    end
                  end
                elsif !post.dig("body").nil? 
                  if post.dig("body").include? "srcset=\""
                    post.dig("body").split("srcset=\"").drop(1).each do |set|
                      img_src = set.split("\"")[0].scan(/\bhttps?:\/\/[^\s]+\.(?:jpg|gif|png|pnj|gifv|webp)\b/)
                      img_src_index = img_src.length > 2 ? 2 : 0
                      signed_url << img_src.last 
                      signed_url_s << img_src[img_src_index]
                    end
                  end
                elsif !post.dig("trail", 0, "content_raw").nil? 
                  if post.dig("trail", 0, "content_raw").include? "srcset=\""
                    post.dig("trail", 0, "content_raw").split("srcset=\"").drop(1).each do |set|
                      img_src = set.split("\"")[0].scan(/\bhttps?:\/\/[^\s]+\.(?:jpg|gif|png|pnj|gifv|webp)\b/)
                      img_src_index = img_src.length > 2 ? 2 : 0
                      signed_url << img_src.last 
                      signed_url_s << img_src[img_src_index]
                    end
                  end
                end

                # text collect
                if !post.dig("title").nil? 
                  if (post.dig("title").to_str).length > 0
                    description = description + post.dig("title")
                  end
                end
                if !post.dig('trail', 0, 'content_raw').nil?
                  if post.dig("trail", 0, "content_raw").length > 0
                    description = description + (post.dig("trail", 0, "content_raw").to_str).gsub(/<div\b[^>]*>(.*?)<\/div>/, '').gsub(/<(.|\n)*?>/, ' ').gsub(/ +/, " ")
                  end
                end

                # author collect
                author = post.dig('blog_name')
                if !post.dig('trail', 0, 'blog').nil?
                  author = post.dig('trail', 0, 'blog', 'name')
                end

                # reblog like collect
                if !post.dig('notes').nil? 
                  post.dig('notes').each do |note|
                    if note.dig('type') == 'like'
                      likes.push(note.dig('blog_name'))
                    elsif note.dig('type') == 'reblog'
                      reblogs.push(note.dig('blog_name'))
                    end
                  end
                end

                # tags collect
                hash_tags = post.dig('tags')
                
                # file type decision 
                file_type = '.txt'
                if signed_url.length > 0
                  file_type = '.avif'
                end

                if !Kernal.exists?(src_url_subset_assigned_id: src_url_subset_assigned_id) && signed_url.length > 0
                  for index in 0 ... signed_url.length
                    @link = Kernal.create(
                      src_url_id: src_user.src_url_id,
                      src_url_subset_id:src_user.id,
                      src_url_subset_assigned_id: src_url_subset_assigned_id,
                      description:description,
                      hashtags: hash_tags,
                      likes: likes,
                      reposts: reblogs,
                      author:author,
                      url:url,
                      time_posted: time_posted,
                      time_scraped: DateTime.now(),
                      file_type: file_type,
                      permissions: src_user.permissions,
                      signed_url: signed_url[index],
                      signed_url_s: signed_url_s[index],
                      signed_url_m: signed_url_s[index],
                      signed_url_l: signed_url[index]
                    )
                    puts signed_url[index]
                  end
                  elsif !Kernal.exists?(src_url_subset_assigned_id: src_url_subset_assigned_id)
                    @link = Kernal.create(
                      src_url_id: src_user.src_url_id,
                      src_url_subset_id:src_user.id,
                      src_url_subset_assigned_id: src_url_subset_assigned_id,
                      description:description,
                      hashtags: hash_tags,
                      likes: likes,
                      author:author,
                      url:url,
                      time_posted: time_posted,
                      time_scraped: DateTime.now(),
                      file_type: file_type,
                      permissions: src_user.permissions,
                      signed_url: nil,
                      signed_url_s: nil,
                      signed_url_m: nil,
                      signed_url_l: nil
                    )
                    puts url
                end
              end
            end
            cnt_post_offset = cnt_post_offset + 50
            if Event.exists?(info: src_user.url)
              Event.where(info: src_user.url)[0].update(
                event_time: DateTime.now(), 
                busy_objects: cnt_post_offset, 
                status: 'scrape in progress'
              )
            end
          end
        end
      end
    end
  end
end
