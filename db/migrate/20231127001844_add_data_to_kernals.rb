class AddDataToKernals < ActiveRecord::Migration[7.0]
  def change
    add_column :kernals, :signed_url_medium, :string
  end
end
