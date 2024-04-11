require './config/environment/'
require 'sidekiq-scheduler'
require 'event_factory'

class TumblrAccountActivity 
  include Sidekiq::Job
  
  reposts = {}
  likes = {}
  @subsets = SrcUrlSubset.where(id: User.find('01f7aea6-dea7-4956-ad51-6dae41e705ca').user_feed.feed_sources)
  @subsets.each do |user|
    @q = Kernal.where(id: SrcUrlSubset.find(user.id).content.contains)
    @q.each do |post|
      if post.reposts != nil
        post.reposts.each do |like|
          if likes.key?(like)
              likes[like].push(user.id)
          else 
            likes[like] = [user.id]
          end
        end
      end
    end
  end
  cnt = 0
  likes.sort_by {|k,v| v.length}.reverse.each do |k, v|
    puts "https://www.tumblr.com/#{k}"
    cnt = cnt + 1
    break if cnt > 50
  end
end


