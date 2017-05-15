class CreateDuplicates < ActiveRecord::Migration[5.1]
  def change
    create_table :duplicates do |t|
      t.integer :entry1_id
      t.integer :entry2_id
      t.text :status

      t.timestamps
    end
  end
end
