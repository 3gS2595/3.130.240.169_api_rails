class AddContentsToMixtape < ActiveRecord::Migration[7.0]
  def change
    add_column :mixtapes, :contents, :uuid
  end
end
