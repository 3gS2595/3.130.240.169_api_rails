class CreateFolders < ActiveRecord::Migration[7.0]
  def change
    create_table :folders, id: :uuid do |t|
      t.string :name
      t.string :contains, array: true, default: []

      t.timestamps
    end
  end
end
