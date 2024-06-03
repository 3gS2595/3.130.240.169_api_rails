require './config/environment/'
require 'sidekiq-scheduler'
require 'json'
require 'event_factory'

class DiscordApi  
  include Sidekiq::Job

  def perform()
    cnt_time_start = Time.now
    
    Discordrb::Paginator.new(nil, :up) do |last_page|
      if last_page && last_page.count < 100  
        []
      else  
        channel.history(100, last_page&.sort_by(&:id)&.first&.id)    
      end  
    end.to_a
  end
end
