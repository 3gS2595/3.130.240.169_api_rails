class CreateSourceUrls < ActiveRecord::Migration[7.0]
  def change
    create_table :source_urls, id: :uuid do |t|
      t.string :domain
      t.string :tag_list
      t.string :source
      t.string :logo_path

      t.timestamps
    end
  end
end
