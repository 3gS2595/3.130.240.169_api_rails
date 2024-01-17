require './config/environment/'
require 'sidekiq-scheduler'
require 'json'
require 'event_factory'

class DiscordApi  
  include Sidekiq::Job

  def perform()
    cnt_time_start = Time.now
  
  end
end
