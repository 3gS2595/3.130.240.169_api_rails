class RenameFoldersInUserFeed < ActiveRecord::Migration[7.0]
  def change
    rename_column :user_feeds, :folders, :mix_folders
    add_column :user_feeds, :src_folders, :string, array: true, default: []
  end
end
