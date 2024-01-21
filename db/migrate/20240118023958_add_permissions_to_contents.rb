class AddPermissionsToContents < ActiveRecord::Migration[7.0]
  def change
    add_column :contents, :permissions, :text, array: true, default: []
  end
end
