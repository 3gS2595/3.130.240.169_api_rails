class CreateContents < ActiveRecord::Migration[7.0]
  def change
    create_table :contents, id: :uuid do |t|
      t.string :contains, array: true, default: []

      t.timestamps
    end
  end
end
