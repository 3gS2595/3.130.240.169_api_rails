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
    @author = @account.name

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
    xp_img_reblog =       "//*[@id='base-container']/div[2]/div[2]/div/div/div[1]/main/div/div/div/div[2]/div/div/div/article/div[1]/div/span/div/div[2]/div/div/button/span/figure/div/img"
    xp_img_standard =     "//*[@id='base-container']/div[2]/div[2]/div/div/div[1]/main/div/div/div/div[2]/div/div/div/article/div[1]/div/span/div/div[1]/button/span/figure/div/img"
    xp_img_tiny =         "//*[@id='base-container']/div[2]/div[2]/div/div/div[1]/main/div/div/div/div[2]/div/div/div/article/div[1]/div/span/div/div/figure/div/img"
    xp_img_tiny_reblog =  "//*[@id='base-container']/div[2]/div[2]/div/div/div/main/div/div/div/div[2]/div/div/div/article/div[1]/div/span/div/div[2]/div/div[1]/div/button/span/figure/div/img"
    xp_img_medium =       "//*[@id='base-container']/div[2]/div[2]/div/div/div[1]/main/div/div/div/div[2]/div/div/div/article/div[1]/div/span/div/div[2]/div/div[1]/button/span/figure/div/img"

    xp_descr = "//*[@id='base-container']/div[2]/div[2]/div/div/div[1]/main/div/div/div/div[2]/div/div/div/article/div[1]/div/span/div/div[2]/p"
    xp_tags = "/html/body/div[1]/div/div[2]/div[2]/div/div/div/main/div/div/div/div[2]/div/div/div/article/div[2]/div/div/a"
    xp_auth = "/html/body/div/div/div[2]/div[2]/div/div/div/main/div/div/div/div[2]/div/div/div/article/div[1]/div/span/div/div[1]/div[1]/div[2]/div/div/span/span/span/a/div"
    xp_reblog_auth = "//*[@id='base-container']/div[2]/div[2]/div/div/div/main/div/div/div/div[2]/div/div/div/article/div[1]/div/span/div/div[1]/div[1]/div/div/div/span/div"

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
    
    if !img_html.empty?
      puts(img_html.attr('srcset').text.scan(/\bhttps?:\/\/[^\s]+\.(?:jpg|gif|png|pnj|gifv)\b/).last)
      tempfile = Down.download(img_html.attr('srcset').text.scan(/\bhttps?:\/\/[^\s]+\.(?:jpg|gif|png|pnj|gifv)\b/).last)
      @imgPath = tempfile.original_filename
      FileUtils.mv(tempfile.path, "/home/pin/crystal_hair/crystal_hair_ui_vueCL/public/feed/#{tempfile.original_filename}")

      # DESCRIPTIOM
      descr = response.xpath(xp_descr)
      if !descr.empty?
        @descri = descr.text
      end
      
      # HASHTAGS
      tags = response.xpath(xp_tags)
      if !tags.empty?
        @hashtags = tags.text
      end

      # POST ACCOUNT
      auth = response.xpath(xp_auth)
      if !auth.empty?
        @author = tags.text
      else
        auth = response.xpath(xp_reblog_auth)
        if !auth.empty?
          @author = tags.text
        end
      end

      if Kernal.exists?(file_path: @imgPath)
        puts('kernal exists')
      else
        puts('kernal absent')
        @link = Kernal.create(
          source_url_id:@source_url_id, 
          hypertext_id:@hypertext_id, 
          file_path:@imgPath, 
          file_name:@imgPath, 
          description:@descri, 
          hashtags:@hashtags, 
          author:@author, 
          time_posted:@time_posted, 
          url:url
        )
      end
    end
  end
end

TumblrSpider.crawl!
