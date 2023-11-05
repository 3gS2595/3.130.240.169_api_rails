require 'tanakai'
require 'down'
require 'fileutils'
require './config/environment/'
require 'aws-sdk-s3'
require 'mini_magick'
require 'date'
require "json"

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
    if @account.name.include? "7twdi29ot5y8og6ndze7m7wexn29cm24"

      @source_url_id = @account.source_url_id
      @hypertext_id = @account.id
      if Kernal.exists?(hypertext_id: @hypertext_id)
        Kernal.where(hypertext_id: @hypertext_id).delete_all
      end
      
      file = File.open "./app/tanakai/xpaths.json"
      @xpaths = JSON.load file

      response.css("url").drop(1).each do |a|
        @url = a.css('loc').text
        if Kernal.exists?(url:@url)
          puts('KERNAL EXISTS')
        elsif a.css('loc').text
          request_to :parse_repo_page, url: absolute_url(a.css("loc").text.sub( /[-0-9+()\\s\\[\\]x]*/, ''), base: url)
        end
      end

    end
  end

  def parse_repo_page(response, url:, data: {})
    # IMG LOCATING, EXTRACTION
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
        if file_type != '.gifv' 
          image.format ".avif"
          image.write "#{save_path}/#{uuid}.avif"
          image.resize "100x100"
          image.write "#{save_path}/nail/#{uuid}.avif"
          file_path = uuid + ".avif"
        else
          image.write "#{save_path}/#{uuid}.gifv"
          image.resize "100x100"
          image.write "#{save_path}/nail/#{uuid}.gifv"
          file_path = uuid + ".gifv"
        end
      end
      
      description = ""
      descr = response.xpath(@xpaths['description'])
      if text.length > 0
        description = text
      elsif !descr.empty?
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
        puts("url= " + url)
        puts(time_posted)
      end
    end
  end
end
TumblrSpider.crawl!
