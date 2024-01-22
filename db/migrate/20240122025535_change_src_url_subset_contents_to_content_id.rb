class ChangeSrcUrlSubsetContentsToContentId < ActiveRecord::Migration[7.0]
  def change
    rename_column :src_url_subsets, :contents, :content_id
  end
end
