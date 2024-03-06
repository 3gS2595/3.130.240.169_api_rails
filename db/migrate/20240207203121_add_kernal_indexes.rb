class AddKernalIndexes < ActiveRecord::Migration[7.0]
  def change
    add_index :kernals, :time_posted
  end
end
