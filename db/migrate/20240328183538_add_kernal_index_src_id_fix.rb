class AddKernalIndexSrcIdFix < ActiveRecord::Migration[7.0]
  def change
    remove_index :kernals, :src_url_subset_assigned_id
    add_index :kernals, :src_url_subset_id
  end
end
