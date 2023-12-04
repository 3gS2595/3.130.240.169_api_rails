require 'tanakai'
require 'down'
require 'fileutils'
require './config/environment/'
require 'aws-sdk-s3'
require 'mini_magick'
require 'date'
require 'json'
require 'colorized_string'

class TumblrSpider < Tanakai::Base
  @@sitemapCnt = 0
  @@sitemaps = 0

  def self.open_spider
    puts("> Starting...")
    @start_urls = SrcUrlSubset.where(
      :src_url_id => SrcUrl.find_by!(name: "tumblr").id).map{|x| (x.url + "/sitemap.xml")}
    @name = "tumblr_spider"
    @engine = :selenium_chrome
    @config = {
      before_request: { delay: 0..0 },
      user_agent: "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3440.84 Safari/537.36"
    }
    puts("\n\n")
  end

  def parse(response, url:, data: {})
    @@sitemapCnt = 0
    @@sitemaps = response.css("sitemap").length()
    response.css("sitemap").reverse.each do |a|
      if a.css('loc').text 
        @@sitemapCnt = @@sitemapCnt + 1
        request_to :parse_sitemap_page, url: absolute_url(a.css("loc").text.sub( /[-0-9+()\\s\\[\\]x]*/, ''), base: url)
      end
    end
  end

  def parse_sitemap_page(response, url:, data: {})
    stripped = url.split("/sitemap")[0]
    @account = SrcUrlSubset.find_by!(url:  stripped)
    @source_url_id = @account.src_url_id
    @hypertext_id = @account.id
    
    file = File.open "./app/tanakai/xpaths.json"
    @xpaths = JSON.load file

    print("START")
    urlCnt = 0
    urlCntNew = 0
    response.css("url").drop(1).each do |a|
      @url = a.css('loc').text
      urlCnt = urlCnt + 1
      if Kernal.exists?(url: absolute_url(a.css("loc").text, base: url))
        print('.')
      else
        print("\n")
        urlCntNew = urlCntNew + 1
        begin
          print ColorizedString[@@sitemapCnt.to_s].colorize(:light_yellow)
          print ("/" + @@sitemaps.to_s)
          print ColorizedString[" " + urlCnt.to_s].colorize(:light_yellow)
          puts ("/" + response.css("url").drop(1).length().to_s)
          request_to :parse_repo_page, url: absolute_url(a.css("loc").text, base: url)
        rescue => e
          puts(e)
          puts("IMG DOWNLOAD/KERNAL CREATION ERROR AT " + url) 
        end
      end
    end
    puts ColorizedString["\nDONE\ncnt:" + urlCnt.to_s + "\nnew:" + urlCntNew.to_s + "\n\n"].colorize(:red)
  end
  
  def green;"\e[32m#{self}\e[0m" end
  def parse_repo_page(response, url:, data: {})
    img_html = nil 
    @xpaths['image'].each do | xpath |
      if response.xpath(xpath).attr('srcset')
        img_html = response.xpath(xpath)
      end
    end
    
    # TXT LOCATING, EXTRACTION
    text = ''
    @xpaths['text'].each do | xpath |
      if response.xpath(xpath).text && text.length == 0
        text = text + response.xpath(xpath).text
      end
    end

    file_type = ".txt"
    if !img_html.nil? || !text.nil?
      # IMAGE FILE
      if !img_html.nil?
        url_path = img_html.attr('srcset').text.scan(/\bhttps?:\/\/[^\s]+\.(?:jpg|gif|png|pnj|gifv)\b/).last
        url_path_s = img_html.attr('srcset').text.scan(/\bhttps?:\/\/[^\s]+\.(?:jpg|gif|png|pnj|gifv)\b/).last
        if(img_html.attr('srcset').text.include?(" 100"))
          url_path_s = img_html.attr('srcset').text.split(" 100")[0]
        end
        file_type = ".avif"
      end
      
      description = ""
      if text.length > 0
        description = text
      elsif !descr.empty?
        @xpaths['description'].each do | xpath |
          if response.xpath(xpath)
            descr = descr + response.xpath(xpath).text
        end
      end

        description = descr.text
      end

      # HASHTAGS
      hashtags = ""
      if response.xpath(@xpaths['hashtags'])
        hashtags = response.xpath(@xpaths['hashtags']).text
      end

      # POST ACCOUNT
      author = "n/a"
      @xpaths['author'].each do | xpath |
          if response.xpath(xpath)
            author = response.xpath(xpath).text
        end
      end
      
      date_script = response.xpath(@xpaths['date']).text
      date = date_script.split("\"date\"")
      date = date[1][2...25]
      time_posted = DateTime.parse(date)

      # API POST
      if !Kernal.exists?(url: url)
        @link = Kernal.create(
          src_url_id:@source_url_id,
          src_url_subset_id:@hypertext_id,
          description:description,
          hashtags:hashtags,
          author:author,
          url:url,
          file_type:file_type,
          time_posted: time_posted,
          permissions: ["01f7aea6-dea7-4956-ad51-6dae41e705ca"],
          signed_url: url_path,
          signed_url_s: url_path_s,
          signed_url_m: url_path_s,
          signed_url_l: url_path,
        )
        print ColorizedString["200 ( OK ) "].colorize(:green)
        puts(url)
      end
    end
  end

  def self.close_spider
    puts("> Stopped!")
  end
end


