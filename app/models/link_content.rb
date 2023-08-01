class LinkContent < ApplicationRecord

  include RansackUUIDHelper
  def self.ransackable_attributes(auth_object = nil)
    ["author", "created_at", "hypertext_id", "id", "names", "post_date", "scrape_interval", "size", "source_url_id", "text_body", "time_initial_scrape", "time_last_scrape", "time_posted", "time_scraped", "updated_at", "url", "word_count"]
  end
  def self.ransackable_associations(auth_object = nil)
    []
  end
end
