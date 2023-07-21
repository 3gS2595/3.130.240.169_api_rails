# tanakai_scheduler.rb
require 'sidekiq-scheduler'
require './config/environment/'

class TanakaiScheduler 
  include Sidekiq::Worker

  def perform
    puts('test')
    TumblrSpider 
  end
end
