class RemoveUserIdFromPermission < ActiveRecord::Migration[7.0]
  def change
    remove_column :permissions, :user_id, :uuid
    add_column :users, :user_feed_id, :uuid
  end
end
