class RemoveContentFromSrcUrlSubset < ActiveRecord::Migration[7.0]
  def change
    remove_column :src_url_subsets, :content
  end
end
