require 'tanakai'
require 'down'
require 'fileutils'
require './config/environment/'
require 'aws-sdk-s3'
require 'mini_magick'
require 'date'

class TumblrSpider < Tanakai::Base
  @start_urls = Hypertext.where(
    :source_url_id => SourceUrl.find_by!(domain: "tumblr.com").id).drop(1).map{|x| (x.url + "/sitemap1.xml")}
  @name = "tumblr_spider"
  @engine = :selenium_firefox
  @config = {
    before_request: { delay: 0..1 },
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
        request_to :parse_repo_page, url: absolute_url(a.css("loc").text.sub( /[-0-9+()\\s\\[\\]x]*/, ''), base: url)
      end
    end
  end

  def parse_repo_page(response, url:, data: {})
    # IMAGES
    image_xpaths = [ 
      "//*[@id='base-container']/div[2]/div[2]/div/div/div[1]/main/div/div/div/div[2]/div/div/div/div/article/div[1]/div/span/div/div[2]/div/div/button/span/figure/div/img",
      "//*[@id='base-container']/div[2]/div[2]/div/div/div[1]/main/div/div/div/div[2]/div/div/div/div/article/div[1]/div/span/div/div[1]/button/span/figure/div/img",
      "//*[@id='base-container']/div[2]/div[2]/div/div/div[1]/main/div/div/div/div[2]/div/div/div/div/article/div[1]/div/span/div/div/figure/div/img",
      "//*[@id='base-container']/div[2]/div[2]/div/div/div[1]/main/div/div/div/div[2]/div/div/div/div/article/div[1]/div/span/div/div[2]/div/div[1]/button/span/figure/div/img",
      "//*[@id='base-container']/div[2]/div[2]/div/div/div[1]/main/div/div/div/div[2]/div/div/div/article/div[1]/div/span/div/div[2]/button/span/figure/div/img",
      "//*[@id='base-container']/div[2]/div[2]/div/div/div[1]/main/div/div/div/div[2]/div/div/div/article/div[1]/div/span/div/div[3]/button/span/figure/div/img",
      "/html/body/div/div/div[2]/div[2]/div/div/div[1]/main/div/div/div/div[2]/div/div/div/article/div[1]/div/span/div/div[2]/div/div[1]/button/span/figure/div/img",
      "//*[@id='base-container']/div[2]/div[2]/div/div/div/main/div/div/div/div[2]/div/div/div/article/div[1]/div/span/div/div[2]/div/div[1]/div/button/span/figure/div/img",
      "//*[@id='base-container']/div[2]/div[2]/div/div/div[1]/main/div/div/div/div[2]/div/div/div/div/article/div[1]/div/span/div/div/button/span/figure/div/img",
      "//*[@id='base-container']/div[2]/div[2]/div/div/div[1]/main/div/div/div/div[2]/div/div/div/div/article/div[1]/div/span/div/div[2]/div/div/button/span/figure/div/img",
      "//*[@id='base-container']/div[2]/div[2]/div/div/div[1]/main/div/div/div/div[2]/div/div/div/div/article/div[1]/div/span/div[1]/div[2]/div/div/button/span/figure/div/img",
      "//*[@id='base-container']/div[2]/div[2]/div/div/div[1]/main/div/div/div/div[2]/div/div/div/div/article/div[1]/div/span/div/div[2]/div/div[1]/button/span/figure/div/img[1]",
      "//*[@id='base-container']/div[2]/div[2]/div/div/div[1]/main/div/div/div/div[2]/div/div/div/div/article/div[1]/div/span/div/div[2]/div/div/div/button/span/figure/div/img[1]",
      "//*[@id='base-container']/div[2]/div[2]/div/div/div[1]/main/div/div/div/div[2]/div/div/div/div/article/div[1]/div/span/div/div[2]/div/div/div/button/span/figure/div/img[1]"
    ]

    # TEXT
    text_xpath = [
      "//*[@id='base-container']/div[2]/div[2]/div/div/div/main/div/div/div/div[2]/div/div/div/article/div[1]/div/span/div/div[1]/p",
      "//*[@id='base-container']/div[2]/div[2]/div/div/div[1]/main/div/div/div/div[2]/div/div/div/div/article/div[1]/div/span/div[1]/div[2]/div/div/p",
      "//*[@id='base-container']/div[2]/div/div[2]/div/div/div/div[1]/main/div/div/div/div[2]/div/div/div/article/div[1]/div/span/div/div/span",
      "//*[@id='base-container']/div[2]/div[2]/div/div/div[1]/main/div/div/div/div[2]/div/div/div/div/article/div[1]/div/span/div/div/span",
      "//*[@id='base-container']/div[2]/div[2]/div/div/div[1]/main/div/div/div/div[2]/div/div/div/article/div[1]/div/span/div/div/h1"
    ]

    # METADATA
    auth_xpath = [
      "//*[@id='base-container']/div[2]/div[2]/div/div/div[1]/main/div/div/div/div[2]/div/div/div/div/article/header/div/div[1]/div[1]/div/span[1]/a",
      "//*[@id='base-container']/div[2]/div[2]/div/div/div[1]/main/div/div/div/div[2]/div/div/div/div/article/div[1]/div/span/div/div[1]/div[1]/div/div/div/span/div",
      "//*[@id='base-container']/div[2]/div[2]/div/div/div[1]/main/div/div/div/div[2]/div/div/div/div/article/div[1]/div/span/div/div[1]/div[1]/div[2]/div/div/span/span/span/a/div"
    ]
    xp_descr = "//*[@id='base-container']/div[2]/div[2]/div/div/div[1]/main/div/div/div/div[2]/div/div/div/div/article/div[1]/div/span/div/div[2]/p"
    xp_tags = "/html/body/div[1]/div/div[2]/div[2]/div/div/div/main/div/div/div/div[2]/div/div/div/article/div[2]/div/div/a"

    # IMG LOCATING, EXTRACTION
    image_xpaths.each do | xpath |
      if response.xpath(xpath).attr('srcset')
        img_html = response.xpath(xpath)
      end
    end
    
    # TXT LOCATING, EXTRACTION
    text = ''
    text_xpaths.each do | xpath |
      if response.xpath(xpath).text && text.length == 0
        text = response.xpath(xpath).text
      end
    end

    file_path = "" 
    file_name = "" 
    file_type = ".txt"
    if !img_html.nil? || !text.nil?
      # IMAGE FILE
      if !img_html.nil?
        url_path = img_html.attr('srcset').text.scan(/\bhttps?:\/\/[^\s]+\.(?:jpg|gif|png|pnj|gifv)\b/).last
        tempfile = Down.download(url_path)
        save_path = "/home/ubuntu"
        file_type = File.extname(tempfile.path)
        uuid = SecureRandom.uuid 
        file_name = tempfile.original_filename
        file_size = File.size(tempfile.path)
        image = MiniMagick::Image.open(tempfile.path)
        image.format ".avif"
        image.write "#{save_path}/#{uuid}.avif"
        image.resize "100x100"
        image.write "#{save_path}/nail/#{uuid}.avif"
        file_path = uuid + ".avif"
      end
      
      description = ""
      descr = response.xpath(xp_descr)
      if text.length > 0
        description = text
      elsif !descr.empty?
        description = descr.text
      end

      # HASHTAGS
      hashtags = ""
      if response.xpath(xp_tags)
        hashtags = response.xpath(xp_tags).text
      end

      # POST ACCOUNT
      author = "n/a"
      auth_xpaths.each do | xpath |
          if response.xpath(xpath)
            author = response.xpath(xpath).text
        end
      end
      
      date_script = response.xpath("//*[@id='tumblr']/script[1]").text
      date = date_script.split("\"date\"")
      date = date[1][2...25]
      time_posted = DateTime.parse(date)

      # API POST
      if !Kernal.exists?(url: url)
        if !img_html.nil? && text.length == 0
          S3Uploader.new(
            File.read("#{save_path}/#{file_path}"), 
            File.read("#{save_path}/nail/#{file_path}"), 
            file_path, 
            'nail_' + file_path
          )
          File.delete(tempfile.path)
          File.delete("#{save_path}/nail/#{file_path}")
        end
        @link = Kernal.create(
          source_url_id:@source_url_id,
          hypertext_id:@hypertext_id,
          file_path:file_path,
          file_name:file_name,
          file_type:file_type,
          size:file_size,
          description:description,
          hashtags:hashtags,
          author:author,
          url:url,
          time_posted: time_posted
        )
        puts('kernal absent')
        puts('source_url_id: ' + @source_url_id)
        puts('hypertext_id' + @hypertext_id)
        puts("file_path= " + file_path)
        puts("file_name= " + file_name)
        puts("description= " + description)
        puts("hashtags= " + hashtags)
        puts("author= " + author)
        puts("url= " + url)
        puts(time_posted)
      end
    end
  end
end
TumblrSpider.crawl!
