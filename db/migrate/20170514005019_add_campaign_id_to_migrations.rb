class AddCampaignIdToMigrations < ActiveRecord::Migration[5.1]
  def change
    add_column :duplicates, :campaign_id, :string, null: false
  end
end
