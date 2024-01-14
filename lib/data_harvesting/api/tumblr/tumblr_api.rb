require './config/environment/'
require 'sidekiq-scheduler'
require 'json'
require 'event_factory'

class TumblrApi  
  include Sidekiq::Job

  def perform()
    cnt_time_start = Time.now

    catch :api_limit_reached do
      @subsets = SrcUrlSubset.where(src_url_id:  SrcUrl.where(name: 'tumblr')[0].id)
      @todo = []

      # initializing_tumblr_account event handling
      @todoCheck = @subsets.filter { |s| s.time_last_scraped_completely == nil }
      @todoCheck.each do |s|
        if !Event.exists?(info: s.url)
          # if unrecognized account, creates new event
          TumblrInitializing(new_s.url)  
          puts 'INITIALIZING: ' + new_s.url.split('/').last
          @todo << s
        else
          # if incompleted initialization, updates event if stale
          init_event = Event.where(info: s.url)[0]
          if (Time.now - init_event.event_time.to_time) > init_event.duration_limit
            init_event.update_attribute(:status, 'resume')
            puts 'RESUMING INITIALIZATION: ' + new_s.url.split('/').last
            @todo << s
          end
        end
      end
      
      # tumblr_update_all event handling
      if @todo.length == 0 
        # terminates if tumblr_update_all is in progress, if heartbeat is stale creates new event 
        if Event.exists?(origin: 'tumblr_updating_all')
          update_event = Event.where(origin: 'tumblr_updating_all')[0]
          if Time.now - update_event.event_time.to_time > update_event.duration_limit
            Event.where(origin: 'tumblr_updating_all')[0].delete
            EventFactory.TumblrUpdatingAll(Thread.current.object_id.to_s)  
            print ( "\n" + 'TUMBLR UPDATE_ALL EVENT CREATED')
            @todo = @subsets.filter { |s| s.time_last_scraped_completely != nil }
          end
        end 
        
        # if tumblr_update_all needed, event does not exist, creates event      
        if !Event.exists?(origin: 'tumblr_updating_all')
          EventFactory.TumblrUpdatingAll(Thread.current.object_id.to_s)  
          print ( "\n" + 'TUMBLR UPDATE_ALL EVENT CREATED')
          @todo = @subsets.filter { |s| s.time_last_scraped_completely != nil }
        end
      end

      # cycles approved accounts
      cnt_requests = 0
      @this_event = Event.where(tid: Thread.current.object_id.to_s)[0]
      @todo.each do | src_user |
        time_previous_last_found_post = src_user.time_last_entry
        time_most_recent_scrape = src_user.time_last_entry
        cnt_searched_posts = 0
        cnt_post_offset = @this_event.origin == 'initializing_tumblr_account' ? Integer(@this_event.busy_objects, exception: false) : 0
        cnt_total_posts = cnt_post_offset 

        # cycles api tokens if request limit reached 
        catch :cycle_posts do
          client = Tumblr::Client.new({
            :consumer_key => Rails.application.credentials.tumblr[:consumer_key_0],
            :consumer_secret => Rails.application.credentials.tumblr[:consumer_secret_0],
            :oauth_token => Rails.application.credentials.tumblr[:oauth_token_0],
            :oauth_token_secret => Rails.application.credentials.tumblr[:oauth_token_secret_0]
          })
          while cnt_post_offset <= cnt_total_posts
            cnt_requests = cnt_requests + 1
            json =  JSON.parse(client.posts(src_user.url.split('/').last + '.tumblr.com', :limit => 50, :offset => cnt_post_offset, :notes_info => true, :reblog_info => true).to_json)
            if json.dig('status') == 429
              client = Tumblr::Client.new({
                :consumer_key => Rails.application.credentials.tumblr[:consumer_key_1],
                :consumer_secret => Rails.application.credentials.tumblr[:consumer_secret_1],
                :oauth_token => Rails.application.credentials.tumblr[:oauth_token_1],
                :oauth_token_secret => Rails.application.credentials.tumblr[:oauth_token_secret_1]
              })
              json =  JSON.parse(client.posts(src_user.url.split('/').last + '.tumblr.com', :limit => 50, :offset => cnt_post_offset, :notes_info => true, :reblog_info => true).to_json)
              if json.dig('status') == 429
                puts('API LIMIT REACHED')
                throw :api_limit_reached
              end
            end

            # iterates through api response's posts
            # (api response debug print)
            cnt_total_posts = json.dig('blog', 'total_posts')
            print ("\n" + 'tumblr-api-:' + '(' + cnt_requests.to_s + ') ' + (Time.at(Time.now - cnt_time_start).utc.strftime "%H:%M:%S") + " ") 
            print (src_user.url.split('/').last + '---' + src_user.url + cnt_searched_posts.to_s + '/' + cnt_total_posts.to_s)
            json.dig('posts').each do |post|
              cnt_searched_posts = cnt_searched_posts + 1

              # records most recent datetime/time_last_entry found
              if DateTime.parse(post.dig("date")) > time_most_recent_scrape
                time_most_recent_scrape = DateTime.parse(post.dig("date"))
              # is up to date check
              elsif DateTime.parse(post.dig("date")) < time_previous_last_found_post
                SrcUrlSubset.find(src_user.id).update_attribute(:time_last_entry, time_most_recent_scrape)
                if Event.exists?(origin: 'tumblr_updating_all')
                  EventFactory.UpdateTumblrUpdatingAll(Thread.current.object_id.to_s)  
                end
                throw :cycle_posts
              end
              
              # creates post kernals for all media found
              TumblrResponseExtract.new(post, src_user)

              # is complete check
              if cnt_searched_posts == cnt_total_posts || (json.dig('posts').length < 50 && json.dig('posts').last == post)
                SrcUrlSubset.find(src_user.id).update_attribute(:time_last_scraped_completely, DateTime.now()) 
                Event.where(info: src_user.url).delete_all
                print ("\n" + 'INITIALIZED ' + src_user.name)
              end
            end

            # updates event heartbeats 
            cnt_post_offset = cnt_post_offset + 50
            if Event.exists?(tid: Thread.current.object_id.to_s, origin: 'initializing_tumblr_account')
              EventFactory.UpdateTumblrInitializing(Thread.current.object_id.to_s, cnt_post_offset)  
            end
            if Event.exists?(tid: Thread.current.object_id.to_s, origin: 'tumblr_updating_all')
              EventFactory.UpdateTumblrUpdatingAll()  
            end
          end
        end
      end
      if Event.exists?(tid: Thread.current.object_id.to_s)
        e = Event.where(tid: Thread.current.object_id.to_s)[0]
        if e.origin == 'tumblr_updating_all' || e.origin == 'initializing_tumblr_account'
          print ("\n" + ' EVENT---' + e.origin + ' COMPLETE') 
          Event.where(tid: Thread.current.object_id.to_s).delete_all
        end
      end
    end
  end
end
