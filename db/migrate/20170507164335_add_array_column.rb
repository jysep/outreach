class AddArrayColumn < ActiveRecord::Migration[5.1]
  def change
    change_column :entries, :age_groups, :text, array: true, default: [], using: "(string_to_array(age_groups, ','))"
    change_column :entries, :themes, :text, array: true, default: [], using: "(string_to_array(themes, ','))"
  end
end
