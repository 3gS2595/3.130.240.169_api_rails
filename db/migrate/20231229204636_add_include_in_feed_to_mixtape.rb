class AddIncludeInFeedToMixtape < ActiveRecord::Migration[7.0]
  def change
    add_column :mixtapes, :include_in_feed, :integer
  end
end
