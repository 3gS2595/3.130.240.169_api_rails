class Content < ApplicationRecord
  def self.ransackable_attributes(auth_object = nil)
    ["contains", "created_at", "id", "permissions", "updated_at"]
  end
end
