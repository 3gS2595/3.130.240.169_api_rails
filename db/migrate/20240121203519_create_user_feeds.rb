class CreateUserFeeds < ActiveRecord::Migration[7.0]
  def change
    create_table :user_feeds, id: :uuid do |t|
      t.string :folders, array: true, default: []
      t.string :feed_mixtape, array: true, default: []
      t.string :feed_sources, array: true, default: []

      t.timestamps
    end
  end
end
