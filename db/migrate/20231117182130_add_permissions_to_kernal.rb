class AddPermissionsToKernal < ActiveRecord::Migration[7.0]
  def change
    add_column :kernals, :permissions, :string, array: true, default: [] 
  end
end
