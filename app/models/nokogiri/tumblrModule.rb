require 'rubygems'
require 'nokogiri'
require 'net/http'
require "down"
require "fileutils"
require 'open-uri'
require 'kimurai'
require './app/models/nokogiri/tumblrPost'
class ScrapperModule
 
  def scrape  
    GithubSpider.crawl!
   
  end

      
end

