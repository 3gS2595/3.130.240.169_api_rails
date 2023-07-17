# github_spider.rb
require 'tanakai'
require './config/environment/'
require "down"
require "fileutils"

class GithubSpider < Tanakai::Base
  @name = "github_spider"
  @engine = :selenium_firefox
  @start_urls = ["https://7twdi29ot5y8og6ndze7m7wexn29cm24.tumblr.com/sitemap1.xml"]
  @config = {
    user_agent: "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3440.84 Safari/537.36",
    before_request: { delay: 1..6 }
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

  if SourceUrl.exists?(domain: "https://www.tumblr.com")
    print('exists\n')
  print("\n")
  else
    print('does not exist')
  print("\n")
  @link = SourceUrl.create(domain:  "https://www.tumblr.com", logo_path: "tumblr_ea6fbf7e15920a6a0a9ee405a2d5e18c_8406c2fd_96.jpg")
  end

  if Hypertext.exists?(url: "https://7twdi29ot5y8og6ndze7m7wexn29cm24.tumblr.com")
    print('exists\n')
  print("\n")
  else
    print('does not exist')
  print("\n")
    @link = Hypertext.create(url:  "https://7twdi29ot5y8og6ndze7m7wexn29cm24.tumblr.com", name: "7twdi29ot5y8og6ndze7m7wexn29cm24", source_url_id: @source_url_id)
  end

  @hypertext_idN = Hypertext.find_by!(url: "https://7twdi29ot5y8og6ndze7m7wexn29cm24.tumblr.com").id
  print("hypertext_id= " + @hypertext_idN)
  print("\n")
  @source_url_idN = SourceUrl.find_by!(domain:  "https://www.tumblr.com").id
  print("source_url_id= " + @source_url_idN)
  print("\n")
  
    def parse(response, url:, data: {})
    response.css("url").each do |a|
      request_to :parse_repo_page, url: absolute_url(a.css("loc").text, base: url)
      @time_posted = a.css('lastmod').text.sub! '+00:00', '0Z'
      @url = a.css('loc').text
      print("time_posted= " + @time_posted)
      print("\n")
      print("urlN= " + @url)
      print("\n")
    end
  end

  def parse_repo_page(response, url:, data: {})
    test = response.xpath("//*[@id='base-container']/div[2]/div[2]/div/div/div/main/div/div/div/div[2]/div/div/div/article/div[1]/div/span/div/div/button/span/figure/div/img")
    if test.attr('srcset')
      tempfile = Down.download(test.attr('srcset').text.scan(/\bhttps?:\/\/[^\s]+\.(?:jpg|gif|png|pnj|gifv)\b/).last)
      @imgPath = tempfile.original_filename
      FileUtils.mv(tempfile.path, "/home/pin/crystal_hair/crystal_hair_ui_vueCL/public/feed/#{tempfile.original_filename}")

      #create new kernal 

    end
    descr = response.xpath("//*[@id='base-container']/div[2]/div[2]/div/div/div[1]/main/div/div/div/div[2]/div/div/div/article/div[1]/div/span/div/div[2]/p")
    if !descr.empty?
      print(descr.text)
      @descri = descr.text
      print("\n")
    end
    tags = response.xpath("/html/body/div[1]/div/div[2]/div[2]/div/div/div/main/div/div/div/div[2]/div/div/div/article/div[2]/div/div/a")
    if !tags.empty?
      print(tags.text)
      @hashtags = tags.text
      print("\n")
    end
    auth = response.xpath("/html/body/div/div/div[2]/div[2]/div/div/div/main/div/div/div/div[2]/div/div/div/article/div[1]/div/span/div/div[1]/div[1]/div[2]/div/div/span/span/span/a/div")
    if !auth.empty?
      print(auth.text)
      @author = tags.text
      print("\n")
    else
      @author = "7twdi29ot5y8og6ndze7m7wexn29cm24"
    end

    if Kernal.exists?(file_path: @imgPath)
      print('KERNAL EXISTS\n')
      print("\n")
    else
      print('KERNAL DOES NOT EXIST')
      print("\n")
      @link = Kernal.create(source_url_id:@source_url_id, hypertext_id:@hypertext_id, file_path:@imgPath, file_name:@imgPath, description:@descri, hashtags:@hashtags, author:@author, time_posted:@time_posted, url:@url)
    end

  end
end

GithubSpider.crawl!
