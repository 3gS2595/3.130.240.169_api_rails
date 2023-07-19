# tanakai_scheduler.rb
require 'sidekiq-scheduler'
require './config/environment/'

class TanakaiScheduler 
  include Sidekiq::Worker

  def perform
    TumblrSpider.crawl! 
  end
end
