require './config/environment/'
require 'sidekiq-scheduler'
require 'tanakai'

class TanakaiScheduler 
  include Sidekiq::Worker

  def perform
    TumblrSpider.crawl!
  end
end
