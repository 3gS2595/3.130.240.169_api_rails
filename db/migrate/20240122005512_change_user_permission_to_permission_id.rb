class ChangeUserPermissionToPermissionId < ActiveRecord::Migration[7.0]
  def change
    rename_column :users, :permission, :permission_id
  end
end
