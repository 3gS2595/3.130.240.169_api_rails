class AddTimeLastEntryToSrcUrlSubset < ActiveRecord::Migration[7.0]
  def change
    add_column :src_url_subsets, :time_last_entry, :datetime
  end
end
