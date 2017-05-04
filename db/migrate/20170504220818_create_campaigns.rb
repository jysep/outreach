class CreateCampaigns < ActiveRecord::Migration[5.1]
  def change
    create_table :campaigns, id: :string do |t|
      t.string :name

      t.timestamps
    end
  end
end
