require './config/environment/'

class EventFactory 

# tumblr_updating_all
  def self.TumblrUpdatingAll(tid)
    @event = Event.create(
      tid: tid,
      event_time: DateTime.now(),
      origin: 'tumblr_updating_all',
      duration_limit: 1000,
      status: 'in progress'
    )
    return @event
  end
  def self.UpdateTumblrUpdatingAll(tid)
    Event.where(tid: tid)[0].update(
      event_time: DateTime.now(), 
      status: 'in progress'
    )
  end

# initializing_tumblr_account
  def self.TumblrInitializing (new_s_url, tid)
    @event = Event.create(
      tid: tid,
      event_time: DateTime.now(),
      info: new_s_url,
      origin: 'initializing_tumblr_account',
      duration_limit: 1000,
      status: 'in progress',
      busy_objects: 0
    )
    return @event
  end
  def self.UpdateTumblrInitializingProg (tid, url, cnt_post_offset)
    Event.where(tid: tid, info: url)[0].update(
      busy_objects: cnt_post_offset,
      status: 'in progress',
      event_time: DateTime.now()
    )
  end
end
