require './config/environment/'

class TumblrResponseExtract 
  def initialize(post, src_user)
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
            time_posted: DateTime.parse(post.dig("date")),
            time_scraped: DateTime.now(),
            file_type: file_type,
            permissions: src_user.permissions,
            signed_url: signed_url[index],
            signed_url_s: signed_url_s[index],
            signed_url_m: signed_url_s[index],
            signed_url_l: signed_url[index]
          )
          @content = SrcUrlSubset.find(src_user.id).content
          new = @content.contains.append(@link.id)
          Content.update(@content.id, :contains => new)
          print "\n" + signed_url[index]
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
            time_posted: DateTime.parse(post.dig("date")),
            time_scraped: DateTime.now(),
            file_type: file_type,
            permissions: src_user.permissions,
            signed_url: nil,
            signed_url_s: nil,
            signed_url_m: nil,
            signed_url_l: nil
          )
          @content = SrcUrlSubset.find(src_user.id).content
          new = @content.contains.append(@link.id)
          Content.update(@content.id, :contains => new)
          print "\n" + url
      end         
    end  
  end
end
