class Hypertext < ApplicationRecord

  include RansackUUIDHelper
  def self.ransackable_associations(auth_object = nil)
    []
  end
  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "id", "logo_path", "name", "scrape_interval", "source_url_id", "time_initial_scrape", "time_last_scrape", "updated_at", "url"]
  end   
end
