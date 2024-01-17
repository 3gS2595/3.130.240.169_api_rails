class RemoveCallsLimitFromSrcUrls < ActiveRecord::Migration[7.0]
  def change
    remove_column :src_urls, :calls_limit, :integer
  end
end
