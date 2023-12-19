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
  def self.open_spider
    puts("> Starting Spider...")
    @name = "tumblr_spider"
    @engine = :selenium_chrome
    @start_urls = (SrcUrlSubset.where(:src_url_id => SrcUrl.find_by!(name: "tumblr").id).map{|x| (x.url + "/sitemap.xml")}).reverse
    @config = {
      before_request: { delay: 1..2 },
    }
    @@siteCnt = 0
    @@sites = @start_urls.length()
    @@mapHash = Hash.new {|h,k| h[k]=[]}
    file = File.open "./app/tanakai/xpaths.json"
    @@xpaths = JSON.load file
    puts("\n\n")
  end

  def parse(response, url:, data: {})
    @@sitemapCnt = 0
    @@siteCnt = @@siteCnt + 1
    urls = Array.new
    response.css("sitemap").reverse.each do |a|
      if  a.css('loc').text && !a.css('loc').text.include?('pootee') && !a.css('loc').text.include?('sitemap-pages') 
        @@sitemapCnt = @@sitemapCnt + 1
        urls << absolute_url(a.css("loc").text.sub( /[-0-9+()\\s\\[\\]x]*/, ''), base: url) 
        @@mapHash[url] << absolute_url(a.css("loc").text.sub( /[-0-9+()\\s\\[\\]x]*/, ''), base: url)
      end
    end

    puts ColorizedString[@@siteCnt.to_s + " / " + @@sites.to_s].colorize(:light_yellow)
    if @@siteCnt == @@sites 
      maps = Hash.new {|h,k| h[k]=[]}
      @@mapHash.each do |m|
        level = 0
        m[1].each do |ur|
          maps[level] << ur
          level = level + 1
        end
      end
      maps.each do |aa|
        puts("---------------")
        puts(aa[1].reverse)
        aa[1].reverse.each do |sc|
          begin
            request_to :parse_sitemap_page, url: sc
          rescue => e
            puts(e)
            puts("SITEMAP SCAN ERROR " + sc) 
          end
        end
      end
    end
  end


  def parse_sitemap_page(response, url:, data: {})
    @@logged_in = false
    print("START")
    urlCnt = 0
    urlCntNew = 0
    posts = Array.new
    response.css("url").drop(1).each do |a|
      urlCnt = urlCnt + 1
      @url = a.css('loc').text
      puts(a.css("loc").text)
      krl = absolute_url(a.css("loc").text, base: url)
      if Kernal.exists?(url: krl)
        print('.')
      else
        puts(Kernal.exists?(:time_posted => DateTime.parse(a.css("lastmod").text)))
        puts(DateTime.parse(a.css("lastmod").text))
        urlCntNew = urlCntNew + 1
        posts.push(absolute_url(a.css("loc").text, base: url))
      end
    end
    in_parallel(:parse_repo_page, posts, threads: 1)
    puts ColorizedString["\nDONE\ncnt:" + urlCnt.to_s + "\nnew:" + urlCntNew.to_s + "\n\n"].colorize(:red)
  end
  
  def parse_repo_page(response, url:, data: {})
    puts(url)
    stripped = url.split(".com/")[1].split("/")[0]
    account = SrcUrlSubset.where('url LIKE ?', '%' + stripped + '%').first
    permissions = account.permissions
    source_url_id = account.src_url_id
    hypertext_id = account.id
    file_type = ".txt"

    # IMAGE FILE
    img_html = nil 
    @@xpaths['image'].each do | xpath |
      if response.xpath(xpath).attr('srcset')
        img_html = response.xpath(xpath)
      end
    end
    if !img_html.nil?
      url_path = img_html.attr('srcset').text.scan(/\bhttps?:\/\/[^\s]+\.(?:jpg|gif|png|pnj|gifv)\b/).last
      url_path_s = img_html.attr('srcset').text.scan(/\bhttps?:\/\/[^\s]+\.(?:jpg|gif|png|pnj|gifv)\b/).last
      if(img_html.attr('srcset').text.include?(" 100"))
        url_path_s = img_html.attr('srcset').text.split(" 100")[0]
      end
      file_type = ".avif"
    end

    # TEXT POST 
    text = ''
    @@xpaths['text'].each do | xpath |
      if response.xpath(xpath).text && text.length == 0
        text = text + response.xpath(xpath).text
      end
    end

    # DESCRIPTION 
    description = text
    @@xpaths['description'].each do | xpath |
      if response.xpath(xpath)
        description = description + response.xpath(xpath).text
      end
    end

    # HASHTAGS
    hashtags = ""
    if response.xpath(@@xpaths['hashtags'])
      hashtags = response.xpath(@@xpaths['hashtags']).text
    end

    # POST ACCOUNT
    author = "n/a"
    @@xpaths['author'].each do | xpath |
      if response.xpath(xpath)
        if response.xpath(xpath).text.length > 3
          author = response.xpath(xpath).text
        end
      end
    end
    
    # DATE POSTED
    date_script = response.xpath(@@xpaths['date']).text
    date = date_script.split("\"date\"")
    if (date[0])
      puts(date[0].length())
      date = date[1][2...25]
      puts(date)
      time_posted = DateTime.parse(date)
    end

    puts(url)
    # SAVE TO ActiveRecord 
    if !Kernal.exists?(url: url) && !Kernal.exists?(signed_url: url_path)
      @link = Kernal.create(
        src_url_id:source_url_id,
        src_url_subset_id:hypertext_id,
        description:description,
        hashtags:hashtags,
        author:author,
        url:url,
        time_posted: time_posted,
        file_type:file_type,
        permissions: permissions,
        signed_url: url_path,
        signed_url_s: url_path_s,
        signed_url_m: url_path_s,
        signed_url_l: url_path
      )
      print ColorizedString["200 ( OK ) "].colorize(:green)
      puts(author + " -- " + hypertext_id + "--" + url)
    end
  end

  def self.close_spider
    puts("> Stopped Spider!")
  end
end


