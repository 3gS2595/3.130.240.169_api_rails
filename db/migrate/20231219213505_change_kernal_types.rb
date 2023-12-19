class ChangeKernalTypes < ActiveRecord::Migration[7.0]
  def change
    change_column :kernals, :reposts, :text, array: true, default: [], using: "(string_to_array(reposts, ','))"
    change_column :kernals, :likes, :text, array: true, default: [], using: "(string_to_array(likes, ','))"
    change_column :kernals, :hashtags, :text, array: true, default: [], using: "(string_to_array(hashtags, ','))"
  end
end
