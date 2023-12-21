require './config/environment/'
require 'sidekiq-scheduler'

class EventCleaner  
  include Sidekiq::Job

  def perform()
    Event.all.each do |e|
      cnt_time_cur = Time.now
      cnt_elapsed = cnt_time_cur - e.event_time.to_time 
      puts(e.info + ' dead? ' + cnt_elapsed.to_s)
      if cnt_elapsed > 40
        puts(e.info + ' IS DEAD, setting to resume')
        e.update_attribute(:status, 'resume')
      end
    end
  end
end
