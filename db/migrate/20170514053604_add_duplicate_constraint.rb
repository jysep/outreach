class AddDuplicateConstraint < ActiveRecord::Migration[5.1]
  def up
    execute %{
      ALTER TABLE duplicates
        ADD CONSTRAINT duplicates_entry_id_order CHECK(entry1_id < entry2_id);
    }
  end

  def down
    execute %{
      ALTER TABLE duplicates
        DROP CONSTRAINT duplicates_entry_id_order;
    }
  end
end
