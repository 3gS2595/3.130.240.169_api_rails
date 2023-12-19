require './config/environment/'
require 'sidekiq-scheduler'
require 'tanakai'

class TanakaiScheduler 
  include Sidekiq::Worker

  def perform
    begin
      TumblrSpider.crawl!
    rescue => e
      puts(e)
      puts("SPIDER FAILURE ") 
    end
  end
end
