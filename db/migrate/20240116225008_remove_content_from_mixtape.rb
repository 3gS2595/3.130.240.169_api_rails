class RemoveContentFromMixtape < ActiveRecord::Migration[7.0]
  def change
    remove_column :mixtapes, :content
  end
end
