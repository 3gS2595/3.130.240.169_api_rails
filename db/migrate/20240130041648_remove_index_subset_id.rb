class RemoveIndexSubsetId < ActiveRecord::Migration[7.0]
  def change
    remove_index :kernals, :src_url_subset_id
    remove_index :kernals, :id
  end
end
