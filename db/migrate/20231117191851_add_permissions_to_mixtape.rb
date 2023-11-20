class AddPermissionsToMixtape < ActiveRecord::Migration[7.0]
  def change
    add_column :mixtapes, :permissions, :string, array: true, default: [] 
  end
end
