require 'tanakai'
require 'down'
require 'fileutils'
require './config/environment/'
require 'aws-sdk-s3'
require 'mini_magick'
require 'date'
require "json"

class TumblrSpider < Tanakai::Base
  @start_urls = SrcUrlSubset.where(
    :src_url_id => SrcUrl.find_by!(name: "tumblr").id).map{|x| (x.url + "/sitemap1.xml")}
  @name = "tumblr_spider"
  @engine = :selenium_firefox
  @config = {
    before_request: { delay: 0..1 },
    user_agent: "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3440.84 Safari/537.36"
  }

  def parse(response, url:, data: {})
    @account = SrcUrlSubset.find_by!(url:  url = (url.sub! '/sitemap1.xml', ''))

    @source_url_id = @account.src_url_id
    @hypertext_id = @account.id
    
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
          image.resize "1000x1000"
          image.write "#{save_path}/nail/l_1000_#{uuid}.avif"
          image.resize "400x400"
          image.write "#{save_path}/nail/m_400_#{uuid}.avif"
          image.resize "160x160"
          image.write "#{save_path}/nail/s_160_#{uuid}.avif"
          file_path = uuid + ".avif"
        else
          image.write "#{save_path}/#{uuid}.gifv"
          image.resize "1000x1000"
          image.write "#{save_path}/nail/l_1000_#{uuid}.gifv"
          image.resize "400x400"
          image.write "#{save_path}/nail/m_400_#{uuid}.gifv"
          image.resize "160x160"
          image.write "#{save_path}/nail/s_160_#{uuid}.gifv"
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
            File.read("#{save_path}/nail/s_160_#{file_path}"), 
            File.read("#{save_path}/nail/m_400_#{file_path}"), 
            File.read("#{save_path}/nail/l_1000_#{file_path}"), 
            file_path, 
          )
          File.delete(tempfile.path)
          File.delete("#{save_path}/nail/s_160_#{file_path}")
          File.delete("#{save_path}/nail/m_400_#{file_path}")
          File.delete("#{save_path}/nail/l_1000_#{file_path}")
        end
        @link = Kernal.create(
          src_url_id:@source_url_id,
          src_url_subset_id:@hypertext_id,
          file_path:file_path,
          file_name:file_name,
          file_type:file_type,
          size:file_size,
          description:description,
          hashtags:hashtags,
          author:author,
          url:url,
          time_posted: time_posted,
          permissions: ["01f7aea6-dea7-4956-ad51-6dae41e705ca"]
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
