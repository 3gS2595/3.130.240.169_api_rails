require './config/environment/'
require 'sidekiq-scheduler'
require 'tanakai'

class TanakaiScheduler 
  include Sidekiq::Worker

  def perform
    begin
      tumApi = TumblrApi.new
      tumApi.intake
    rescue => e
      puts(e)
      puts("SPIDER FAILURE ") 
    end
  end
end
