class RemoveKernalSrcAssignedId < ActiveRecord::Migration[7.0]
  def change
    remove_index :kernals, :src_url_subset_assigned_id
    remove_index :kernals, :time_posted
  end
end
