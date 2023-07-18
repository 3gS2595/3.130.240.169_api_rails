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
  
  @source_url_id = ""
  @hypertext_id = ""
  @time_posted = "" 
  @author = ""
  @description = ""
  @time_posted = ""
  @descri = ""
  @hashtags = ""
  @imgPath = ""
  @url ="" 

  @contentSavePath = "/home/pin/crystal_hair/crystal_hair_ui_vueCL/public/feed/"
  @descrXpath = "//*[@id='base-container']/div[2]/div[2]/div/div/div[1]/main/div/div/div/div[2]/div/div/div/article/div[1]/div/span/div/div[2]/p"
  @tagsXpath = "/html/body/div[1]/div/div[2]/div[2]/div/div/div/main/div/div/div/div[2]/div/div/div/article/div[2]/div/div/a"
  @reblogAuthXpath = "/html/body/div[1]/div/div[2]/div[2]/div/div/div/main/div/div/div/div[2]/div[1]/div/div/article/div[1]/div/span/div/div[1]/div[1]/div[2]/div/div/span/span/span/a/div"
  @postAuthXpath = "/html/body/div/div/div[2]/div[2]/div/div/div/main/div/div/div/div[2]/div/div/div/article/div[1]/div/span/div/div[1]/div[1]/div[2]/div/div/span/span/span/a/div"

  if !SourceUrl.exists?(domain: "tumblr.com")
    @link = SourceUrl.create(domain: "tumblr.com", logo_path: "tumblr.jpg")
  end

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
    imgHtml = response.xpath("//*[@id='base-container']/div[2]/div[2]/div/div/div[1]/main/div/div/div/div[2]/div/div/div/article/div[1]/div/span/div/div[1]/button/span/figure/div/img")
    if imgHtml.attr('srcset')
      puts(imgHtml.attr('srcset').text.scan(/\bhttps?:\/\/[^\s]+\.(?:jpg|gif|png|pnj|gifv)\b/).last)
      tempfile = Down.download(imgHtml.attr('srcset').text.scan(/\bhttps?:\/\/[^\s]+\.(?:jpg|gif|png|pnj|gifv)\b/).last)
      @imgPath = tempfile.original_filename
      FileUtils.mv(tempfile.path, "/home/pin/crystal_hair/crystal_hair_ui_vueCL/public/feed/#{tempfile.original_filename}")
    elsif response.xpath("//*[@id='base-container']/div[2]/div[2]/div/div/div[1]/main/div/div/div/div[2]/div/div/div/article/div[1]/div/span/div/div/figure/div/img").attr('srcset')
      imgHtml = response.xpath("//*[@id='base-container']/div[2]/div[2]/div/div/div[1]/main/div/div/div/div[2]/div/div/div/article/div[1]/div/span/div/div/figure/div/img")
      puts(imgHtml.attr('srcset').text.scan(/\bhttps?:\/\/[^\s]+\.(?:jpg|gif|png|pnj|gifv)\b/).last)
      tempfile = Down.download(imgHtml.attr('srcset').text.scan(/\bhttps?:\/\/[^\s]+\.(?:jpg|gif|png|pnj|gifv)\b/).last)
      @imgPath = tempfile.original_filename
      FileUtils.mv(tempfile.path, "/home/pin/crystal_hair/crystal_hair_ui_vueCL/public/feed/#{tempfile.original_filename}")
    elsif response.xpath("//*[@id='base-container']/div[2]/div[2]/div/div/div[1]/main/div/div/div/div[2]/div/div/div/article/div[1]/div/span/div/div[2]/div/div[1]/button/span/figure/div/img").attr('srcset')
      imgHtml = response.xpath("//*[@id='base-container']/div[2]/div[2]/div/div/div[1]/main/div/div/div/div[2]/div/div/div/article/div[1]/div/span/div/div[2]/div/div[1]/button/span/figure/div/img")
      puts(imgHtml.attr('srcset').text.scan(/\bhttps?:\/\/[^\s]+\.(?:jpg|gif|png|pnj|gifv)\b/).last)
      tempfile = Down.download(imgHtml.attr('srcset').text.scan(/\bhttps?:\/\/[^\s]+\.(?:jpg|gif|png|pnj|gifv)\b/).last)
      @imgPath = tempfile.original_filename
      FileUtils.mv(tempfile.path, "/home/pin/crystal_hair/crystal_hair_ui_vueCL/public/feed/#{tempfile.original_filename}")
    end


    descr = response.xpath(@descrXpath)
    if !descr.empty?
      puts(descr.text)
      @descri = descr.text
    end

    tags = response.xpath(@tagsXpath)
    if !tags.empty?
      puts(tags.text)
      @hashtags = tags.text
    end

    auth = response.xpath(@reblogAuthXpath)
    if !auth.empty?
      puts(auth.text)
      puts("REBLOG")
      @author = tags.text
    else
      auth = response.xpath()
      if !auth.empty?
        puts(auth.text)
        @author = tags.text
      end
    end
    if Kernal.exists?(file_path: @imgPath)
      puts('KERNAL EXISTS\n')
    else
      puts('KERNAL DOES NOT EXIST')
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

TumblrSpider.crawl!
