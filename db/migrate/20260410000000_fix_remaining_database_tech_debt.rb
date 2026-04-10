class FixRemainingDatabaseTechDebt < ActiveRecord::Migration[8.0]
  def up
    # 1. Enforce User Constraints
    change_column_null :users, :name, false
    change_column_null :users, :language, false, "en"

    # 2. Enforce Cycle Engine Constraints
    change_column_null :cycle_entries, :phase, false
    add_index :cycle_entries, [:user_id, :date], unique: true, name: "index_cycle_entries_on_user_id_and_date_unique"

    # 3. Optimize Performance
    add_index :reminders, [:user_id, :active], name: "index_reminders_on_user_id_and_active"
    add_index :calendar_events, [:user_id, :date], name: "index_calendar_events_on_user_id_and_date"
  end

  def down
    # Reverse performance indexes
    remove_index :calendar_events, name: "index_calendar_events_on_user_id_and_date"
    remove_index :reminders, name: "index_reminders_on_user_id_and_active"

    # Reverse cycle engine constraints
    remove_index :cycle_entries, name: "index_cycle_entries_on_user_id_and_date_unique"
    change_column_null :cycle_entries, :phase, true

    # Reverse user constraints
    change_column_null :users, :language, true
    change_column_null :users, :name, true
  end
end
