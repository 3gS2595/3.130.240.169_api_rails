require './config/environment/'
require 'sidekiq-scheduler'
require 'json'
require 'event_factory'

class TumblrApiUpdate 
  include Sidekiq::Job

  def perform()
    catch :api_limit_reached do
      cnt_time_start = Time.now
      @subsets = SrcUrlSubset.where(src_url_id:  SrcUrl.where(name: 'tumblr')[0].id).reject{ |s| s.name == 'deactivated918273729' }
      @this_event = nil
      @page_size = 50
      @todo = []

      # tumblr_update_all event handling
      if @todo.length == 0 
        # terminates if tumblr_update_all is in progress, if heartbeat is stale creates new event 
        if Event.exists?(origin: 'tumblr_updating_all')
          update_event = Event.where(origin: 'tumblr_updating_all')[0]
          if Time.now - update_event.event_time.to_time > update_event.duration_limit
            Event.where(origin: 'tumblr_updating_all')[0].delete
            @this_event = EventFactory.TumblrUpdatingAll(Thread.current.object_id.to_s)  
            @todo = @subsets.filter { |s| s.time_last_scraped_completely != nil }
            puts('TUMBLR UPDATE_ALL EVENT CREATED')
          end
        end 
        
        # if tumblr_update_all needed, event does not exist, creates event      
        if !Event.exists?(origin: 'tumblr_updating_all')
          @this_event = EventFactory.TumblrUpdatingAll(Thread.current.object_id.to_s)  
          @todo = @subsets.filter { |s| s.time_last_scraped_completely != nil }
          puts('TUMBLR UPDATE_ALL EVENT CREATED')
        end
      end

      # cycles approved accounts
      cnt_requests = 0
      cur_api_key = 0
      extractor = TumblrResponseExtract.new()
      @todo.each do | src_user |
        permissions = []
        User.all.each do |user|
          if user.permission.src_url_subsets.include?(src_user.id)
            permissions.push(user.id)
          end
        end
        time_previous_last_found_post = !src_user.time_last_entry.nil? ? src_user.time_last_entry : DateTime.new(1900,1,1.0)
        time_most_recent_scrape = !src_user.time_last_entry.nil? ? src_user.time_last_entry : DateTime.new(1900,1,1.0)
        cnt_post_offset = @this_event.busy_objects != nil ? Integer(@this_event.busy_objects, exception: false) : 0
        cnt_total_posts = cnt_post_offset 
        cnt_searched_posts = 0

        client = Tumblr::Client.new({
          :consumer_key => Rails.application.credentials.tumblr[:consumer_key_0],
          :consumer_secret => Rails.application.credentials.tumblr[:consumer_secret_0],
          :oauth_token => Rails.application.credentials.tumblr[:oauth_token_0],
          :oauth_token_secret => Rails.application.credentials.tumblr[:oauth_token_secret_0]
        })

        catch :cycle_posts do
          while cnt_post_offset <= cnt_total_posts
            cnt_requests = cnt_requests + 1
            json =  JSON.parse(client.posts(src_user.url.split('/').last + '.tumblr.com', :limit => @page_size, :offset => cnt_post_offset, :notes_info => true, :reblog_info => true).to_json)

            if json.dig('status') == 404
              throw :cycle_posts
            end

            # cycles api tokens if request limit reached 
            if json.dig('status') == 429
              cur_api_key = 1
              client = Tumblr::Client.new({
                :consumer_key => Rails.application.credentials.tumblr[:consumer_key_1],
                :consumer_secret => Rails.application.credentials.tumblr[:consumer_secret_1],
                :oauth_token => Rails.application.credentials.tumblr[:oauth_token_1],
                :oauth_token_secret => Rails.application.credentials.tumblr[:oauth_token_secret_1]
              })
              json =  JSON.parse(client.posts(src_user.url.split('/').last + '.tumblr.com', :limit => @page_size, :offset => cnt_post_offset, :notes_info => true, :reblog_info => true).to_json)
              if json.dig('status') == 429
                cur_api_key = 3
                client = Tumblr::Client.new({
                  :consumer_key => Rails.application.credentials.tumblr[:consumer_key_2],
                  :consumer_secret => Rails.application.credentials.tumblr[:consumer_secret_2],
                  :oauth_token => Rails.application.credentials.tumblr[:oauth_token_2],
                  :oauth_token_secret => Rails.application.credentials.tumblr[:oauth_token_secret_2]
                })
                json =  JSON.parse(client.posts(src_user.url.split('/').last + '.tumblr.com', :limit => @page_size, :offset => cnt_post_offset, :notes_info => true, :reblog_info => true).to_json)
                if json.dig('status') == 429
                  puts('API LIMIT REACHED')
                  throw :api_limit_reached
                end
              end
            end

            # iterates through api response's posts
            # (api response debug print)
            cnt_total_posts = json.dig('blog', 'total_posts')
            print ("\n" + '-- API --TUMBLR-key-' + cur_api_key.to_s + '(' + cnt_requests.to_s.rjust(4, ' ') + '@ ' + (Time.at(Time.now - cnt_time_start).utc.strftime "%H:%M:%S") + ")=-") 
            print (src_user.url.split('/').last.ljust(20, '-')[0,20] + '-= ' + (cnt_post_offset.to_s + '/' + cnt_total_posts.to_s).ljust(8,' ') + '-=> ' + src_user.url )
            new_k = []

            json.dig('posts').each do |post|
              cnt_searched_posts = cnt_searched_posts + 1
              time_posted = DateTime.parse(post.dig("date"))

              # is up to date checks
              if time_posted > time_most_recent_scrape
                time_most_recent_scrape = time_posted
              elsif ((time_posted < time_previous_last_found_post || time_posted == time_previous_last_found_post) && src_user.time_last_scraped_completely != nil)
                SrcUrlSubset.find(src_user.id).update(time_last_entry: time_most_recent_scrape)
                src_user.content.contains.concat(new_k)
                src_user.content.save
                throw :cycle_posts
              end 

              # creates post kernals for all media found
              src_url_subset_assigned_id = post.dig("id")
              if !Kernal.exists?(src_url_subset_assigned_id: src_url_subset_assigned_id)
                new_k.concat(extractor.extract(post, src_user, permissions, src_url_subset_assigned_id, time_posted))
              else
                puts ("˪".rjust(39, ' ') + ' post exists')
                if (cnt_searched_posts == 1) 
                  SrcUrlSubset.find(src_user.id).update(time_last_entry: time_posted)
                  print('updated recent post datetime')
                end
              end

              # is complete check
              if cnt_searched_posts == cnt_total_posts || (json.dig('posts').length < @page_size && json.dig('posts').last == post)
                SrcUrlSubset.find(src_user.id).update(time_last_scraped_completely: DateTime.now(), time_last_entry: time_most_recent_scrape)
                Event.where(info: src_user.url).delete_all
                print ("\n" + 'INITIALIZED ' + src_user.name)
              end
            end
            src_user.content.contains.concat(new_k)
            src_user.content.save
            # updates event heartbeats 
            cnt_post_offset = cnt_post_offset + @page_size
            if @this_event.origin == 'initializing_tumblr_account'
              @this_event.update(
                busy_objects: cnt_post_offset,
                status: 'in progress',
                event_time: DateTime.now()
              )
            elsif @this_event.origin == 'tumblr_updating_all'
              @this_event.update(
                event_time: DateTime.now(), 
                status: 'in progress'
              )
            end
          end
        end
      end
      # Delete completed event
      if @this_event != nil
        @this_event.delete
      end
      # new line for sidekiq "done" print
      puts()
    end
  end
end
