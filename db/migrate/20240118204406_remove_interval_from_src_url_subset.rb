class RemoveIntervalFromSrcUrlSubset < ActiveRecord::Migration[7.0]
  def change
    remove_column :src_url_subsets, :scrape_interval
  end
end
