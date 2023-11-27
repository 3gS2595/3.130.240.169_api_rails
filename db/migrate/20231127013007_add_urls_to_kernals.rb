class AddUrlsToKernals < ActiveRecord::Migration[7.0]
  def change
    add_column :kernals, :signed_url_s, :string
    add_column :kernals, :signed_url_m, :string
    add_column :kernals, :signed_url_l, :string

    remove_column :kernals, :signed_url_nail
    remove_column :kernals, :signed_url_medium
  end
end
