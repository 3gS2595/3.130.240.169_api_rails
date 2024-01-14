require './config/environment/'

class EventFactory 

# tumblr_updating_all
  def self.TumblrUpdatingAll(tid)
    @event = Event.create(
      tid: tid,
      event_time: DateTime.now(),
      origin: 'tumblr_updating_all',
      duration_limit: 120,
      status: 'in progress'
    )
  end
  def self.UpdateTumblrUpdatingAll(tid)
    Event.where(tid: tid)[0].update(
      event_time: DateTime.now(), 
      status: 'in progress'
    )
  end

# initializing_tumblr_account
  def self.TumblrInitializing (sew_s_url, tid)
    @event = Event.create(
      tid: tid,
      event_time: DateTime.now(),
      info: new_s.url,
      origin: 'initializing_tumblr_account',
      duration_limit: 120,
      status: 'in progress',
      busy_objects: 0
    )
  end
  def self.UpdateTumblrInitializing (tid, cnt_post_offset)
    Event.where(tid: tid)[0].update(
      event_time: DateTime.now(), 
      busy_objects: cnt_post_offset,
      status: 'in progress'
    )
  end
end
