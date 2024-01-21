class RemovePermissionsToContents < ActiveRecord::Migration[7.0]
  def change
    remove_column :contents, :permissions
  end
end
