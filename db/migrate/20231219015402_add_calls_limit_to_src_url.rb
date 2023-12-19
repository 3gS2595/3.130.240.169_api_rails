class AddCallsLimitToSrcUrl < ActiveRecord::Migration[7.0]
  def change
    add_column :src_urls, :calls_limit, :integer
  end
end
