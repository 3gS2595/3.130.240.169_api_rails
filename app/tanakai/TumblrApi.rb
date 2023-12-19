
require './config/environment/'
require 'json'
# Authenticate via OAuth
client = Tumblr::Client.new({
  :consumer_key => 'BrOeZ7eAIi4lddglzkUa1hoUksLfpvfiZWS8BcUCUIA3Lx4bXl',
  :consumer_secret => 'Z7THjfHuLI6FsNZOj8VdX7MxCS3IOccDrvBDiEKuGuPrbP9bpb',
  :oauth_token => 'DsFHbvc7ejWmuqgbxXuaxFne5CI3G18ceuPMzcESKdxlS5gek5',
  :oauth_token_secret => 'hYzXog9YyziwEGKTiE8kZwiFtwabbUWDAMv0DMX4oa4sEgJfLD'
})
user = "7twdi29ot5y8og6ndze7m7wexn29cm24"
# Make the request
newPosts = 0

offset = 0
total_posts = 1 
request_cnt = 0
account = SrcUrlSubset.where('url LIKE ?', '%' + user + '%').first
permissions = account.permissions
src_url_id = account.src_url_id
src_url_subset_id = account.id

while offset < total_posts
  request_cnt = request_cnt + 1
  response = client.posts (user + '.tumblr.com'), :limit => 50, :offset => offset
  json = JSON.parse(response.to_json)
  total_posts = json['blog']['total_posts']
  json['posts'].each do |post|
    src_url_subset_assigned_id = post["id"]
    author = '' 
    url = post["post_url"]
    description = ''
    hash_tags = ''
    time_posted = DateTime.parse(post["date"])
    signed_url = ''
    signed_url_s = ''
    permissions = ''


    if !post["post_url"].nil? 
      if Kernal.where("url like ?", "%" + post["post_url"].gsub("blog/view/", "") + "%").length == 0
        newPosts = newPosts + 1
        puts post["post_url"].gsub("blog/view/", "")

        # image collect
        if !post["body"].nil? 
          if post["body"].include? "img src=\""
            puts post["body"] ? post["body"].split("img src=\"")[1].split("\"")[0] : 'value don\'t exist and returns nil'
          end
        elsif !post["image_permalink"].nil? 
          signed_url = post["image_permalink"] ? post["image_permalink"] : 'value don\'t exist and returns nil'
        end

        # text collect
        if !post["title"].nil? 
          if (post["title"].to_str).length > 0
            puts("title")
            puts post["title"]
          end
        end
        if !post["trail"][0].nil? 
          if !post['trail'][0]['content_raw'].nil?
            if (post["trail"][0]["content_raw"]).length > 0
              puts "found"
              puts (post["trail"][0]["content_raw"].to_str).gsub(/<div\b[^>]*>(.*?)<\/div>/, '').gsub(/<(.|\n)*?>/, ' ').gsub(/ +/, " ")
            end
          end
        end
        if !Kernal.exists?(src_url_subset_assigned_id: tumblr_post_id)
          @link = Kernal.create(
            src_url_id:src_url_id,
            src_url_subset_id:src_url_subset_id,
            src_url_subset_assigned_id: src_url_subset_assigned_id,
            description:description,
            hashtags:hashtags,
            author:author,
            url:url,
            time_posted: time_posted,
            file_type:file_type,
            permissions: permissions,
            signed_url: signed_url,
            signed_url_s: signed_url_s,
            signed_url_m: signed_url_s,
            signed_url_l: signed_url
          )
        end
      else
        puts "kernal exists"
      end
    end
  end
  offset = offset + 50
end
puts newPosts
