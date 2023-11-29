class CreateSrcUrlSubsets < ActiveRecord::Migration[7.0]
  def change
    create_table :src_url_subsets, id: :uuid do |t|
      t.uuid :src_url_id
      t.string :url
      t.string :name
      t.integer :scrape_interval
      t.timestamp :time_last_scraped
      t.string :permissions, array: true, default: []

      t.timestamps
    end
  end
end
