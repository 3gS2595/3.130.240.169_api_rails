class CreatePermissions < ActiveRecord::Migration[7.0]
  def change
    create_table :permissions, id: :uuid do |t|
      t.uuid :user_id
      t.string :mixtapes, array: true, default: []
      t.string :kernals, array: true, default: []
      t.string :src_url_subsets, array: true, default: []

      t.timestamps
    end
  end
end
