class CreatePermissions < ActiveRecord::Migration[5.1]
  def change
    create_table :permissions do |t|
      t.string :email
      t.string :campaign_id
      t.string :level

      t.timestamps
    end
  end
end
