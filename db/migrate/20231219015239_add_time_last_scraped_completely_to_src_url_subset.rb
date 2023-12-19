class AddTimeLastScrapedCompletelyToSrcUrlSubset < ActiveRecord::Migration[7.0]
  def change
    add_column :src_url_subsets, :time_last_scraped_completely, :datetime
  end
end
