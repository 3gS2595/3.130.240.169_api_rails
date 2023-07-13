class CreateKernals < ActiveRecord::Migration[7.0]
  def change
    create_table :kernals, id: :uuid do |t|
      t.uuid :source_url_id
      t.uuid :hypertext_id
      t.string :file_type
      t.string :file_name
      t.string :file_path
      t.string :url
      t.float :size
      t.string :author
      t.datetime :time_posted
      t.datetime :time_scraped
      t.string :description
      t.string :key_words
      t.string :hashtags
      t.string :likes
      t.string :reposts

      t.timestamps
    end
  end
end
