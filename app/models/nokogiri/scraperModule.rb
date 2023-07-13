
class ScrapperModule
      require 'nokogiri'
require 'open-uri'
require 'pry'
require 'open-uri'

  def scrape_content
    
    html = URI.open("finalhotdesert")

    doc = Nokogiri::HTML(html)
    print(doc.css("a"))
  end
endrequire 'open-uri'
