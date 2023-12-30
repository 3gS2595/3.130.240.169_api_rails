class AddContentToSrcUrlSubset < ActiveRecord::Migration[7.0]
  def change
    add_column :src_url_subsets, :content, :text, array: true, default: []
  end
end
