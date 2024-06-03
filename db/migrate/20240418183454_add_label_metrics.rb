class AddLabelMetrics < ActiveRecord::Migration[7.0]
  def change
    add_column :kernals, :label_metrics, :float, array: true, default: []
  end
end
