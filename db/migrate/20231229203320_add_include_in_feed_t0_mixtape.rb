class AddIncludeInFeedT0Mixtape < ActiveRecord::Migration[7.0]
  def change
    add_column :mixtapes, :include_in_feed, :text, array: true, default: []
  end
end
