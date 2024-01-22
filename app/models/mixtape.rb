class Mixtape < ApplicationRecord
  include RansackHelper
    belongs_to :content # the cell table has a person_id
  def self.ransackable_associations(auth_object = nil)
    []
  end
  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "id", "updated_at", "name"]
  end   
end
