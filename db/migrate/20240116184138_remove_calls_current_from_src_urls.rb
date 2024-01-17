class RemoveCallsCurrentFromSrcUrls < ActiveRecord::Migration[7.0]
  def change
    remove_column :src_urls, :calls_current, :integer
  end
end
