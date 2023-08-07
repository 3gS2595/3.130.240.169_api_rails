require 'tanakai'
require 'down'
require 'fileutils'
require './config/environment/'
require 'aws-sdk-s3'
require 'mini_magick'
require 'date'

class TumblrSpider < Tanakai::Base
  @start_urls = Hypertext.where(
    :source_url_id => SourceUrl.find_by!(domain: "tumblr.com").id).map{|x| (x.url + "/sitemap1.xml")}
  @name = "tumblr_spider"
  @engine = :selenium_firefox
  @config = {
    before_request: { delay: 0..2 },
    user_agent: "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3440.84 Safari/537.36"
  }

  def parse(response, url:, data: {})
    @account = Hypertext.find_by!(url:  url = (url.sub! '/sitemap1.xml', ''))
    @source_url_id = @account.source_url_id
    @hypertext_id = @account.id

    response.css("url").drop(1).each do |a|
      @url = a.css('loc').text
      if Kernal.exists?(url:@url)
        puts('KERNAL EXISTS')
      elsif a.css('loc').text
        request_to :parse_repo_page, url: absolute_url(a.css("loc").text, base: url)
      end
    end
  end

  def parse_repo_page(response, url:, data: {})

    # IMAGES
    xp_img_reblog =      "//*[@id='base-container']/div[2]/div[2]/div/div/div[1]/main/div/div/div/div[2]/div/div/div/article/div[1]/div/span/div/div[2]/div/div/button/span/figure/div/img"
    xp_img_standard =    "//*[@id='base-container']/div[2]/div[2]/div/div/div[1]/main/div/div/div/div[2]/div/div/div/article/div[1]/div/span/div/div[1]/button/span/figure/div/img"
    xp_img_tiny =        "//*[@id='base-container']/div[2]/div[2]/div/div/div[1]/main/div/div/div/div[2]/div/div/div/article/div[1]/div/span/div/div/figure/div/img"
    xp_img_tiny_reblog = "//*[@id='base-container']/div[2]/div[2]/div/div/div/main/div/div/div/div[2]/div/div/div/article/div[1]/div/span/div/div[2]/div/div[1]/div/button/span/figure/div/img"
    xp_img_medium =      "//*[@id='base-container']/div[2]/div[2]/div/div/div[1]/main/div/div/div/div[2]/div/div/div/article/div[1]/div/span/div/div[2]/div/div[1]/button/span/figure/div/img"
    xp_img_reblog_m =    "/html/body/div/div/div[2]/div[2]/div/div/div[1]/main/div/div/div/div[2]/div/div/div/article/div[1]/div/span/div/div[2]/div/div[1]/button/span/figure/div/img"
    
    # TEXT
    xp_txt_standard =    "//*[@id='base-container']/div[2]/div[2]/div/div/div/main/div/div/div/div[2]/div/div/div/article/div[1]/div/span/div/div[1]/p"
    xp_txt_reblog =      "//*[@id='base-container']/div[2]/div[2]/div/div/div[1]/main/div/div/div/div[2]/div/div/div/article/div[1]/div/span/div[1]/div[2]/div/div/p"
    xp_text_mist =       "//*[@id='base-container']/div[2]/div/div[2]/div/div/div/div[1]/main/div/div/div/div[2]/div/div/div/article/div[1]/div/span/div/div/span"
    xp_text_standards =  "//*[@id='base-container']/div[2]/div[2]/div/div/div[1]/main/div/div/div/div[2]/div/div/div/article/div[1]/div/span/div/div/span"

    # METADATA
    xp_descr =           "//*[@id='base-container']/div[2]/div[2]/div/div/div[1]/main/div/div/div/div[2]/div/div/div/article/div[1]/div/span/div/div[2]/p"
    xp_tags =            "/html/body/div[1]/div/div[2]/div[2]/div/div/div/main/div/div/div/div[2]/div/div/div/article/div[2]/div/div/a"
    xp_auth =            "//*[@id='base-container']/div[2]/div[2]/div/div/div[1]/main/div/div/div/div[2]/div/div/div/article/header/div/div[1]/div[1]/div/span[1]/a"
    xp_reblog_auth =     "//*[@id='base-container']/div[2]/div[2]/div/div/div[1]/main/div/div/div/div[2]/div/div/div/article/div[1]/div/span/div/div[1]/div[1]/div/div/div/span/div"
    xp_reblog_two_auth = "//*[@id='base-container']/div[2]/div[2]/div/div/div[1]/main/div/div/div/div[2]/div/div/div/article/div[1]/div/span/div/div[1]/div[1]/div[2]/div/div/span/span/span/a/div"

    # IMG LOCATING, EXTRACTION
    # size standard
    if response.xpath(xp_img_standard).attr('srcset')
      img_html = response.xpath(xp_img_standard)
    # size tiny
    elsif response.xpath(xp_img_tiny).attr('srcset')
      img_html = response.xpath(xp_img_tiny)
    # size tiny? rebglog
    elsif response.xpath(xp_img_reblog).attr('srcset')
      img_html = response.xpath(xp_img_reblog)
    # size tiny? rebglog
    elsif response.xpath(xp_img_tiny_reblog).attr('srcset')
      img_html = response.xpath(xp_img_tiny_reblog)
    # size medium ?
    elsif response.xpath(xp_img_tiny_reblog).attr('srcset')
      img_html = response.xpath(xp_img_tiny_reblog)
    elsif response.xpath(xp_img_reblog_m).attr('srcset')
      img_html = response.xpath(xp_img_reblog_m)
    end
    
    # TXT LOCATING, EXTRACTION
    text = ''
    if response.xpath(xp_txt_standard).text && text.length == 0
      text = response.xpath(xp_txt_standard).text
      puts("ping ping" + text)
    # size tiny
    end
    if response.xpath(xp_txt_reblog).text && text.length == 0
      text = response.xpath(xp_txt_reblog).text
      puts("ping ping" + text)
    # size tiny? rebglog
    end
    if response.xpath(xp_text_mist).text && text.length == 0
      text = response.xpath(xp_text_mist).text
      puts("ping ping" + text)
    end
    if response.xpath(xp_text_standards).text && text.length == 0
      text = response.xpath(xp_text_standards).text
      puts("ping ping" + text)
    end

    file_path = "" 
    file_type = ".txt"
    if !img_html.nil? || !text.nil?
      # IMAGE FILE
      if !img_html.nil?
        file_type = ".img"
        url_path = img_html.attr('srcset').text.scan(/\bhttps?:\/\/[^\s]+\.(?:jpg|gif|png|pnj|gifv)\b/).last
        tempfile = Down.download(url_path)
        save_path = "/home/ubuntu"
        file_path = tempfile.original_filename
        FileUtils.mv(tempfile.path, "#{save_path}/#{tempfile.original_filename}")
        image = MiniMagick::Image.open("#{save_path}/#{tempfile.original_filename}")
        image.path #=> "#{save_path}/img/#{tempfile.original_filename}"
        image.resize "180x180"
        image.write "#{save_path}/nail/#{tempfile.original_filename}"
      end
      file_path = tempfile.original_filename
      FileUtils.mv(tempfile.path, "/home/ubuntu/img/#{tempfile.original_filename}")
      Aws.use_bundled_cert!
      client = Aws::S3::Client.new(
        access_key_id: Rails.application.credentials.aws[:access_key_id],
        secret_access_key: Rails.application.credentials.aws[:secret_access_key],
        endpoint: 'https://nyc3.digitaloceanspaces.com',
        force_path_style: false,
        region: 'us-east-1'
      )
      client.put_object({
        bucket: "crystal-hair",
        key: file_path,
        body: File.read("/home/ubuntu/img/#{tempfile.original_filename}"),
        acl: "public-read"
      }) 
      
      description = ""
      descr = response.xpath(xp_descr)
      if text.length > 0
        description = text
      elsif !descr.empty?
        description = descr.text
      end

      # HASHTAGS
      hashtags = ""
      tags = response.xpath(xp_tags)
      if !tags.empty?
        hashtags = tags.text
      end

      # POST ACCOUNT
      author = ""
      auth = response.xpath(xp_auth)
      if !auth.empty?
        author = auth.text
      end
      auth = response.xpath(xp_reblog_auth)
      if !auth.empty?
        author = auth.text
      end
      auth = response.xpath(xp_reblog_two_auth)
      if !auth.empty?
        author = auth.text
      end
      
      date_script = response.xpath("//*[@id='tumblr']/script[1]").text
      date = date_script.split("\"date\"")
      date = date[1][2...25]
      puts(date)
      time_posted = DateTime.parse(date)

      # API POST
      puts(text.length)
      puts("\"" + description + "\"")
      if Kernal.exists?(file_path: file_path) && text.length == 0 || file_path == nil
        puts('kernal REJECTED EXISTS?')
        puts('kernal absent')
        puts('source_url_id: ' + @source_url_id)
        puts('hypertext_id' + @hypertext_id)
        puts(img_html)
      elsif !Kernal.exists?(url: url)
        puts('kernal absent')
        puts('source_url_id: ' + @source_url_id)
        puts('hypertext_id' + @hypertext_id)
        puts("file_path= " + file_path)
        puts("file_name= " + file_path)
        puts("description= " + description)
        puts("hashtags= " + hashtags)
        puts("author= " + author)
        puts("url= " + url)
        puts(time_posted)

        if !img_html.nil? && text.length == 0
          Aws.use_bundled_cert!
          s3client = Aws::S3::Client.new(
            access_key_id: Rails.application.credentials.aws[:access_key_id],
            secret_access_key: Rails.application.credentials.aws[:secret_access_key],
            endpoint: 'https://nyc3.digitaloceanspaces.com',
            force_path_style: false,
            region: 'us-east-1'
          )
          s3client.put_object({
            bucket: "crystal-hair",
            key: file_path,
            body: File.read("#{save_path}/#{tempfile.original_filename}"),
            acl: "private"
          })
          s3client.put_object({
            bucket: "crystal-hair-nail",
            key: file_path,
            body: File.read("#{save_path}/nail/#{tempfile.original_filename}"),
            acl: "private"
          })
        end
        if !img_html.nil?
          File.delete("#{save_path}/#{tempfile.original_filename}")
          File.delete("#{save_path}/nail/#{tempfile.original_filename}")
        end

        @link = Kernal.create(
          source_url_id:@source_url_id,
          hypertext_id:@hypertext_id,
          file_path:file_path,
          file_name:file_path,
          file_type:file_type,
          description:description,
          hashtags:hashtags,
          author:author,
          url:url,
          time_posted: time_posted
        )
      end

      # CLEAN UP
    end
  end
end

TumblrSpider.crawl!
