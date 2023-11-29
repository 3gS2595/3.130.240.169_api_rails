class CreateSrcUrls < ActiveRecord::Migration[7.0]
  def change
    create_table :src_urls, id: :uuid do |t|
      t.string :name
      t.string :url
      t.string :permissions, array: true, default: []

      t.timestamps
    end
  end
end
