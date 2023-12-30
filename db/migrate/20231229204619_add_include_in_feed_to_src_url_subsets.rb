class AddIncludeInFeedToSrcUrlSubsets < ActiveRecord::Migration[7.0]
  def change
    add_column :src_url_subsets, :include_in_feed, :integer
  end
end
