class CreateHypertexts < ActiveRecord::Migration[7.0]
  def change
    create_table :hypertexts, id: :uuid do |t|
      t.uuid :source_url_id
      t.string :url
      t.string :name
      t.integer :scrape_interval
      t.datetime :time_last_scrape
      t.datetime :time_initial_scrape
      t.string :logo_path 
      t.timestamps
    end
  end
end
