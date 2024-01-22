class Content < ApplicationRecord
  has_one :mixtape 
  has_one :src_url_subset
  def self.ransackable_attributes(auth_object = nil)
    ["contains", "created_at", "id", "permissions", "updated_at"]
  end
end
