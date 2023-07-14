require 'rubygems'
require 'nokogiri'
require 'net/http'
require "down"
require "fileutils"
require 'open-uri'
require './config/environment/'

class ScrapperModule
  
  def scrape
    doc = Nokogiri::HTML(Net::HTTP.get(URI("https://www.finalhotdesert.com/past")))
    
    outLinks = doc.css('div.text-block a').map { |link| link['href'] }
    outLinks.each do |e|
      url = e.sub! 'http://', 'https://'
      link = Nokogiri::HTML(Net::HTTP.get(URI(e)))
      
      # create new link_content
      @link = LinkContent.create(source_url_id: "2d7f3c0a-8699-49c8-829f-435cb57262cb", url: e)

      link.css('div.container').css('div.page-element').each do|n|
        imgName = n.attr('data-prefix')
        imgType = n.attr('data-suffix')
        if imgName
          imgPath = imgName.split('/').last + "." + imgType
          tempfile = Down.download(imgName + "." + imgType)
          FileUtils.mv(tempfile.path, "/home/pin/crystal_hair/crystal_hair_ui_vueCL/public/feed/#{tempfile.original_filename}")

          #create new kernal 
          Kernal.create(hypertext_id:@link.id, file_path: imgPath, file_name:imgName, file_type:imgType)
        end
      end
    end
  end
end

