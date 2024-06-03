class FixLabelMetrics < ActiveRecord::Migration[7.0]
  def change
    remove_column :kernals, :label_metrics
  end
end
