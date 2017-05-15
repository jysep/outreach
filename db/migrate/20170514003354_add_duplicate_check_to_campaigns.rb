class AddDuplicateCheckToCampaigns < ActiveRecord::Migration[5.1]
  def change
    add_column :campaigns, :last_duplicate_check, :timestamptz
  end
end
