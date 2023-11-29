class CreateMixtapes < ActiveRecord::Migration[7.0]
  def change
    create_table :mixtapes, id: :uuid do |t|
      t.string :name
      t.string :content, array: true, default: []
      t.string :permissions, array: true, default: []

      t.timestamps
    end
  end
end
