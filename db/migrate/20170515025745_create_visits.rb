class CreateVisits < ActiveRecord::Migration[5.1]
  def up
    create_table :visits do |t|
      t.integer :entry_id
      t.string :team
      t.date :date
      t.string :time
      t.string :outcome
      t.string :themes, array: true, default: []
      t.string :notes

      t.timestamps
    end
    execute %{
      INSERT INTO visits (entry_id, team, date, time, outcome, themes, notes, created_at, updated_at)
      SELECT id, team, date, time, outcome, themes, notes, created_at, updated_at
      FROM entries
    }
    remove_column :entries, :team
    rename_column :entries, :date, :last_visit
    remove_column :entries, :time
    rename_column :entries, :outcome, :last_outcome
    remove_column :entries, :themes
    remove_column :entries, :notes
  end

  def down
    add_column :entries, :team, :string
    rename_column :entries, :last_visit, :date
    add_column :entries, :time, :string
    rename_column :entries, :last_outcome, :outcome
    add_column :entries, :themes, :string, array: true, default: []
    add_column :entries, :notes, :string
    execute %{
      UPDATE entries
        SET team=v.team, time=v.time, themes=v.themes, notes=v.notes
      FROM visits v
      WHERE v.entry_id=entries.id
    }
    drop_table :visits
  end
end
