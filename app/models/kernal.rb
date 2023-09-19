class Kernal < ApplicationRecord

  include RansackHelper
  def self.ransackable_associations(auth_object = nil)
    []
  end
  def self.ransackable_attributes(auth_object = nil)
    ["author", "created_at", "description", "file_name", "signed_url", "signed_url_nail", "file_path", "file_type", "hashtags", "hypertext_id", "id", "key_words", "likes", "post_date", "reposts", "scrape_interval", "size", "source_url_id", "time_initial_scrape", "time_last_scrape", "time_posted", "time_scraped", "updated_at", "url", "word_count"]
  end
end
