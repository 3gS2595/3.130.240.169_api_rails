class RemoveContentsFromSrcUrlSubset < ActiveRecord::Migration[7.0]
  def change
    add_column :src_url_subsets, :contents, :uuid
  end
end
