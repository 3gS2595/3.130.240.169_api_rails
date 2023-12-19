require './config/environment/'
require 'json'

client = Tumblr::Client.new({
  :consumer_key => 'BrOeZ7eAIi4lddglzkUa1hoUksLfpvfiZWS8BcUCUIA3Lx4bXl',
  :consumer_secret => 'Z7THjfHuLI6FsNZOj8VdX7MxCS3IOccDrvBDiEKuGuPrbP9bpb',
  :oauth_token => 'DsFHbvc7ejWmuqgbxXuaxFne5CI3G18ceuPMzcESKdxlS5gek5',
  :oauth_token_secret => 'hYzXog9YyziwEGKTiE8kZwiFtwabbUWDAMv0DMX4oa4sEgJfLD'
})

user = "thejogging"
account = SrcUrlSubset.where('url LIKE ?', '%' + user + '%').first
permissions = account.permissions
src_url_id = account.src_url_id
src_url_subset_id = account.id

post_offset = 0
total_posts = 1 
request_cnt = 0
newPosts = 0

while post_offset < total_posts
  request_cnt = request_cnt + 1
  puts post_offset
  api_response = client.posts (user + '.tumblr.com'), :limit => 50, :offset => post_offset, :notes_info => true, :reblog_info => true
  post_offset = post_offset + 50
  json = JSON.parse(api_response.to_json)
  total_posts = json['blog']['total_posts']
  
  json['posts'].each do |post|
      newPosts = newPosts + 1
    src_url_subset_assigned_id = post["id"]
    author = nil 
    url = post["post_url"]
    description = ''
    hash_tags = []
    time_posted = DateTime.parse(post["date"])
    signed_url = []
    signed_url_s = []
    likes = []
    reblogs = []

    if !Kernal.exists?(src_url_subset_assigned_id: src_url_subset_assigned_id)
      # image collect
      if !post['photos'].nil?
        post['photos'].each do |photo|
          signed_url << photo['alt_sizes'][0]['url']
          index = photo['alt_sizes'].length - 3 > -1 ? post['photos'][0]['alt_sizes'].length - 3 : 0
          signed_url_s << photo['alt_sizes'][index]['url']
        end
      elsif !post["body"].nil? 
        if post["body"].include? "srcset=\""
          post["body"].split("srcset=\"").drop(1).each do |set|
            set = set.split("\"")[0]
            src_index = set.scan(/\bhttps?:\/\/[^\s]+\.(?:jpg|gif|png|pnj|gifv|webp)\b/)
            s_i = src_index.length > 2 ? 2 : 0
            signed_url << src_index.last 
            signed_url_s << src_index[s_i]
          end
        end
      end

      # text collect
      if !post["title"].nil? 
        if (post["title"].to_str).length > 0
          description = description + post["title"]
        end
      end
      if !post["trail"][0].nil? 
        if !post['trail'][0]['content_raw'].nil?
          if (post["trail"][0]["content_raw"]).length > 0
            description = description + (post["trail"][0]["content_raw"].to_str).gsub(/<div\b[^>]*>(.*?)<\/div>/, '').gsub(/<(.|\n)*?>/, ' ').gsub(/ +/, " ")
          end
        end
      end

      # author collect
      author = post['blog_name']
      if !post["trail"][0].nil? 
        if !post['trail'][0]['blog'].nil?
          author = post['trail'][0]['blog']['name']
        end
      end

      # reblog like collect
      if !post['notes'].nil? 
        post['notes'].each do |note|
          if note['type'] == 'like'
            likes.push(note['blog_name'])
          elsif note['type'] == 'reblog'
            reblogs.push(note['blog_name'])
          end
        end
      end

      # tags collect
      hash_tags = post['tags']
      
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
            author:author,
            url:url,
            time_posted: time_posted,
            file_type: file_type,
            permissions: permissions,
            signed_url: signed_url[index],
            signed_url_s: signed_url_s[index],
            signed_url_m: signed_url_s[index],
            signed_url_l: signed_url[index]
          )
          puts signed_url[index]
          puts signed_url_s[index]

          puts url
          puts '-_-'
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
            file_type: file_type,
            permissions: permissions,
            signed_url: nil,
            signed_url_s: nil,
            signed_url_m: nil,
            signed_url_l: nil
          )
      end
    else
      puts "kernal exists"
      puts url
    end
  end
end
puts newPosts


__END__
    if Kernal.exists?(src_url_subset_assigned_id: src_url_subset_assigned_id)
      Kernal.where(src_url_subset_assigned_id: src_url_subset_assigned_id).delete_all
    end
