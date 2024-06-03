class AddLabelsToKernel < ActiveRecord::Migration[7.0]
  def change
    add_column :kernals, :label_metrics, :text, array: true, default: []
    add_column :kernals, :label, :string
  end
end
