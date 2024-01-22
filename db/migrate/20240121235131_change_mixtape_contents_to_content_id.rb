class ChangeMixtapeContentsToContentId < ActiveRecord::Migration[7.0]
  def change
    rename_column :mixtapes, :contents, :content_id
  end
end
