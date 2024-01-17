require './config/environment/'
require 'sidekiq-scheduler'
require 'event_factory'

class TumblrAccountActivity 
  include Sidekiq::Job
  
    cnt_time_start = Time.now
    
    @subsets = SrcUrl.where(name: 'tumblr')[0]
    
    tumblr_posts = Kernal.where(src_url_id: @subsets.id)
    puts (tumblr_posts.count)
end


