require './config/environment/'
require 'json'

client = Tumblr::Client.new({
  :consumer_key => 'BrOeZ7eAIi4lddglzkUa1hoUksLfpvfiZWS8BcUCUIA3Lx4bXl',
  :consumer_secret => 'Z7THjfHuLI6FsNZOj8VdX7MxCS3IOccDrvBDiEKuGuPrbP9bpb',
  :oauth_token => 'DsFHbvc7ejWmuqgbxXuaxFne5CI3G18ceuPMzcESKdxlS5gek5',
  :oauth_token_secret => 'hYzXog9YyziwEGKTiE8kZwiFtwabbUWDAMv0DMX4oa4sEgJfLD'
})

SrcUrlSubset.all.each do | src_user |
  if src_user.url.include? ('tumblr')
    user = src_user.url.split('/').last
    puts(user)
    permissions = src_user.permissions
    src_url_id = src_user.src_url_id
    src_url_subset_id = src_user.id

    post_offset = 0
    total_posts = 1 
    request_cnt = 0
    newPosts = 0
    searched_posts = 0

    catch :cycle_posts do
      while post_offset < total_posts
        request_cnt = request_cnt + 1
        puts(request_cnt)
        puts(searched_posts)
        puts(total_posts)
        api_response = client.posts (user + '.tumblr.com'), :limit => 50, :offset => post_offset, :notes_info => true, :reblog_info => true
        post_offset = post_offset + 50
        json = JSON.parse(api_response.to_json)
        total_posts = json.dig('blog', 'total_posts')
     
        json.dig('posts').each do |post|
          src_user = SrcUrlSubset.find(src_user.id)
          searched_posts = searched_posts + 1
          newPosts = newPosts + 1
          src_url_subset_assigned_id = post.dig("id")
          author = nil 
          url = post.dig("post_url")
          description = ''
          hash_tags = []
          time_posted = DateTime.parse(post.dig("date"))
          signed_url = []
          signed_url_s = []
          likes = []
          reblogs = []

          # is up to date check
          if src_user.time_last_entry != nil && src_user.time_last_scraped_completely != nil
            if time_posted > src_user.time_last_entry
              SrcUrlSubset.find(src_user.id).update_attribute(:time_last_entry, time_posted)
            else
              puts('quiting early')
              throw :cycle_posts
            end
          end
          # latest post check
          if src_user.time_last_entry == nil
            SrcUrlSubset.find(src_user.id).update_attribute(:time_last_entry, time_posted)
          elsif time_posted > src_user.time_last_entry
            SrcUrlSubset.find(src_user.id).update_attribute(:time_last_entry, time_posted)
          end
          # completion check
          if searched_posts == total_posts
            SrcUrlSubset.find(src_user.id).update_attributeupdate(:time_last_scraped_completely, DateTime.now()) 
            puts('last post searched')
          end

          if !Kernal.exists?(src_url_subset_assigned_id: src_url_subset_assigned_id)
            # image collect
            if !post.dig('photos').nil?
              post.dig('photos').each do |photo|
                signed_url << photo.dig('alt_sizes', 0, 'url')
                index = photo.dig('alt_sizes').length - 3 > -1 ? post.dig('photos', 0, 'alt_sizes').length - 3 : 0
                signed_url_s << photo.dig('alt_sizes', index, 'url')
              end
            elsif !post.dig("body").nil? 
              if post.dig("body").include? "srcset=\""
                post.dig("body").split("srcset=\"").drop(1).each do |set|
                  set = set.split("\"")[0]
                  src_index = set.scan(/\bhttps?:\/\/[^\s]+\.(?:jpg|gif|png|pnj|gifv|webp)\b/)
                  s_i = src_index.length > 2 ? 2 : 0
                  signed_url << src_index.last 
                  signed_url_s << src_index[s_i]
                end
              end
            end

            # text collect
            if !post.dig("title").nil? 
              if (post.dig("title").to_str).length > 0
                description = description + post.dig("title")
              end
            end
            if !post.dig("trail", 0).nil? 
              if !post.dig('trail', 0, 'content_raw').nil?
                if post.dig("trail", 0, "content_raw").length > 0
                  description = description + (post.dig("trail", 0, "content_raw").to_str).gsub(/<div\b[^>]*>(.*?)<\/div>/, '').gsub(/<(.|\n)*?>/, ' ').gsub(/ +/, " ")
                end
              end
            end

            # author collect
            author = post.dig('blog_name')
            if !post.dig("trail", 0).nil? 
              if !post.dig('trail', 0, 'blog').nil?
                author = post.dig('trail', 0, 'blog', 'name')
              end
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
                  src_url_id:src_url_id,
                  src_url_subset_id:src_url_subset_id,
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
                  permissions: permissions,
                  signed_url: signed_url[index],
                  signed_url_s: signed_url_s[index],
                  signed_url_m: signed_url_s[index],
                  signed_url_l: signed_url[index]
                )
                puts url
              end
              elsif !Kernal.exists?(src_url_subset_assigned_id: src_url_subset_assigned_id)
                @link = Kernal.create(
                  src_url_id:src_url_id,
                  src_url_subset_id:src_url_subset_id,
                  src_url_subset_assigned_id: src_url_subset_assigned_id,
                  description:description,
                  hashtags: hash_tags,
                  likes: likes,
                  author:author,
                  url:url,
                  time_posted: time_posted,
                  time_scraped: DateTime.now(),
                  file_type: file_type,
                  permissions: permissions,
                  signed_url: nil,
                  signed_url_s: nil,
                  signed_url_m: nil,
                  signed_url_l: nil
                )
                puts url
            end
          else
            print "."
          end
        end
      end
    end
  end
end
puts newPosts


__END__

        if Kernal.exists?(src_url_subset_assigned_id: src_url_subset_assigned_id)
          Kernal.where(src_url_subset_assigned_id: src_url_subset_assigned_id).delete_all
        end
