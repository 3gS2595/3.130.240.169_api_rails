class CreateEvents < ActiveRecord::Migration[7.0]
  def change
    create_table :events, id: :uuid do |t|
      t.string :status
      t.string :tid
      t.datetime :event_time
      t.string :origin
      t.string :info
      t.string :busy_objects
      t.integer :duration_limit
      t.string :permissions, array: true, default: []
      t.timestamps
    end
  end
end
