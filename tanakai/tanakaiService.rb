require './config/environment/'

class TanakaiService
  
  public def initialize
    Hypertext.all.each do |hypertext|
      @source_url_id = hypertext.source_url_id
      @url = hypertext.url
      @name = hypertext.name
      @scrape_interval = hypertext.scrape_interval
      @time_last_scraped = hypertext.time_last_scrape
      @logo_path = hypertext.logo_path
      print(@source_url_id)
      print("\n")
      print(@name)
      print("\n")
    end
  end
end


