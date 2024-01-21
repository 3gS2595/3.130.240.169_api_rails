class AddMixtapeIndex < ActiveRecord::Migration[7.0]
  def change
    add_index :kernals, :src_url_subset_id
  end
end
