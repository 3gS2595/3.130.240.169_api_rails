class AddAssignedIdToSrcUrlSubset < ActiveRecord::Migration[7.0]
  def change
    add_column :kernals, :src_url_subset_assigned_id, :text
  end
end
