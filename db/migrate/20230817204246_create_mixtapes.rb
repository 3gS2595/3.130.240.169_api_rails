class CreateMixtapes < ActiveRecord::Migration[7.0]
  def change
    create_table :mixtapes, id: :uuid do |t|
      t.string :name

      t.timestamps
    end
  end
end
