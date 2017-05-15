class AddIndexToEntries < ActiveRecord::Migration[5.1]
  def change
    add_index :entries, :campaign_id
    add_index :duplicates, :campaign_id
    add_index :permissions, :campaign_id
    add_index :permissions, :email
    add_index :users, :email
    add_index :duplicates, [:entry1_id, :entry2_id], unique: true
  end
end
