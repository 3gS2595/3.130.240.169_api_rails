class AddContentsToEvent < ActiveRecord::Migration[7.0]
  def change
    add_column :events, :contents, :text, array: true, default: []
  end
end
