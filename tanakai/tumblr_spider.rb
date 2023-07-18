# tumblr_spider.rb
require 'tanakai'
require './config/environment/'
require "down"
require "fileutils"


class TumblrSpider < Tanakai::Base
  @name = "tumblr_spider"
  @engine = :selenium_firefox
  @config = {
    user_agent: "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3440.84 Safari/537.36",
    before_request: { delay: 2..3 }
  }
  
  @source_url_id = SourceUrl.find_by!(domain: "tumblr.com").id
  @start_urls = Hypertext.where(:source_url_id => @source_url_id).map{|x| (x.url + "/sitemap1.xml")}

  def parse(response, url:, data: {})
    @account = Hypertext.find_by!(url:  url = (url.sub! '/sitemap1.xml', ''))
    @source_url_id = @account.source_url_id
    @hypertext_id = @account.id

    response.css("url").each do |a|
      @url = a.css('loc').text
      if Kernal.exists?(url:@url)
        puts('KERNAL EXISTS')
      else
        request_to :parse_repo_page, url: absolute_url(a.css("loc").text, base: url)
        @time_posted = a.css('lastmod').text.sub! '+00:00', '0Z'
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

    xp_descr =           "//*[@id='base-container']/div[2]/div[2]/div/div/div[1]/main/div/div/div/div[2]/div/div/div/article/div[1]/div/span/div/div[2]/p"
    xp_tags =            "/html/body/div[1]/div/div[2]/div[2]/div/div/div/main/div/div/div/div[2]/div/div/div/article/div[2]/div/div/a"
    xp_auth =            "//*[@id='base-container']/div[2]/div[2]/div/div/div[1]/main/div/div/div/div[2]/div/div/div/article/header/div/div[1]/div[1]/div/span[1]/a"
    xp_reblog_auth =     "//*[@id='base-container']/div[2]/div[2]/div/div/div[1]/main/div/div/div/div[2]/div/div/div/article/div[1]/div/span/div/div[1]/div[1]/div/div/div/span/div"
    xp_reblog_two_auth =     "//*[@id='base-container']/div[2]/div[2]/div/div/div[1]/main/div/div/div/div[2]/div/div/div/article/div[1]/div/span/div/div[1]/div[1]/div[2]/div/div/span/span/span/a/div"



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
    end
    
    if !img_html.nil?
      # IMAGE FILE
      file_path = ""
      puts(img_html.attr('srcset').text.scan(/\bhttps?:\/\/[^\s]+\.(?:jpg|gif|png|pnj|gifv)\b/).last)
      tempfile = Down.download(img_html.attr('srcset').text.scan(/\bhttps?:\/\/[^\s]+\.(?:jpg|gif|png|pnj|gifv)\b/).last)
      file_path = tempfile.original_filename
      FileUtils.mv(tempfile.path, "/home/pin/crystal_hair/crystal_hair_ui_vueCL/public/feed/#{tempfile.original_filename}")

      # DESCRIPTIOM
      description = ""
      descr = response.xpath(xp_descr)
      if !descr.empty?
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

      # API POST
      if Kernal.exists?(file_path: file_path)
        puts('kernal exists')
      else
        puts('kernal absent')
        puts(@source_url_id)
        puts(@hypertext_id)
        puts("file_path= " + file_path)
        puts("file_name= " + file_path)
        puts("description= " + description)
        puts("hashtags= " + hashtags)
        puts("author= " + author)
        puts("url= " + url)
        @link = Kernal.create(
          source_url_id:@source_url_id, 
          hypertext_id:@hypertext_id, 
          file_path:file_path, 
          file_name:file_path, 
          description:description, 
          hashtags:hashtags, 
          author:author, 
          url:url
        )
      end
    end
  end
end

TumblrSpider.crawl!
