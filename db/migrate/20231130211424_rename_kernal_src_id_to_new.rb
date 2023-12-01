class RenameKernalSrcIdToNew < ActiveRecord::Migration[7.0]
  def change
    rename_column :kernals, :source_url_id, :src_url_id
    rename_column :kernals, :hypertext_id, :src_url_subset_id
  end
end
