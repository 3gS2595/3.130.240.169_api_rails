class AddPermissionsFixecdToContents < ActiveRecord::Migration[7.0]
  def change
    add_column :contents, :permissions, :string, array: true, default: []
  end
end
