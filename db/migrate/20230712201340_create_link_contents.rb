class CreateLinkContents < ActiveRecord::Migration[7.0]
  def change
    create_table :link_contents, id: :uuid do |t|
      t.uuid :source_url_id
      t.string :names
      t.string :url
      t.datetime :post_date
      t.integer :word_count
      t.string :author
      t.string :text_body

      t.timestamps
    end
  end
end
