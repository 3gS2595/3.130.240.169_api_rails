class AddChangeTypes < ActiveRecord::Migration[7.0]
  def change
      remove_column :mixtapes, :include_in_feed      
      remove_column :src_url_subsets, :include_in_feed
  end
end
