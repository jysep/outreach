class CreateEntries < ActiveRecord::Migration[5.1]
  def change
    create_table :entries do |t|
      t.string :campaign_id
      t.string :user_email
      t.string :team
      t.date   :date
      t.string :time
      t.string :street
      t.string :street_number
      t.string :unit_number
      t.string :outcome
      t.string :people
      t.string :contact
      t.string :age_groups
      t.string :themes
      t.string :notes

      t.timestamps
    end
  end
end
