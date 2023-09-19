class SourceUrl < ApplicationRecord
  include RansackHelper
  has_many :kernals
  has_many :hypertexts
  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "domain", "hypertext_id", "id", "logo_path", "post_date", "scrape_interval", "size", "source", "source_url_id", "tag_list", "time_initial_scrape", "time_last_scrape", "time_posted", "time_scraped", "updated_at", "word_count"]
  end
  def self.ransackable_associations(auth_object = nil)
    ["hypertexts", "kernals"]
  end
end
