class AddIndexForTumblrPostId < ActiveRecord::Migration[7.0]
  def change
    add_index :kernals, :src_url_subset_assigned_id
  end
end
