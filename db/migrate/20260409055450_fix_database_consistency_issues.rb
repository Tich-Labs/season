class FixDatabaseConsistencyIssues < ActiveRecord::Migration[8.0]
  def up
    # 1. Remove redundant indexes (covered by composite indexes)
    remove_index :symptom_logs, name: "index_symptom_logs_on_user_id"
    remove_index :cycle_entries, name: "index_cycle_entries_on_user_id"

    # 2. Add NOT NULL to columns that models already validate presence on
    change_column_null :symptom_logs, :date, false
    change_column_null :superpower_logs, :date, false
    change_column_null :cycle_phase_contents, :phase, false
    change_column_null :cycle_phase_contents, :locale, false
    change_column_null :cycle_entries, :date, false
    change_column_null :calendar_events, :title, false
    change_column_null :calendar_events, :date, false

    # 3. Fix boolean columns: backfill NULLs, add default + NOT NULL
    execute "UPDATE symptom_logs SET sexual_intercourse = false WHERE sexual_intercourse IS NULL"
    change_column_null :symptom_logs, :sexual_intercourse, false

    execute "UPDATE reminders SET active = false WHERE active IS NULL"
    change_column_default :reminders, :active, false
    change_column_null :reminders, :active, false

    execute "UPDATE cycle_entries SET period_end = false WHERE period_end IS NULL"
    change_column_default :cycle_entries, :period_end, false
    change_column_null :cycle_entries, :period_end, false

    execute "UPDATE cycle_entries SET period_start = false WHERE period_start IS NULL"
    change_column_default :cycle_entries, :period_start, false
    change_column_null :cycle_entries, :period_start, false

    execute "UPDATE users SET onboarding_completed = false WHERE onboarding_completed IS NULL"
    change_column_default :users, :onboarding_completed, false
    change_column_null :users, :onboarding_completed, false

    # 4. Add missing unique indexes
    remove_index :superpower_logs, name: "index_superpower_logs_on_user_id"
    remove_index :superpower_logs, name: "index_superpower_logs_on_date"
    add_index :superpower_logs, [:user_id, :date], unique: true, name: "index_superpower_logs_on_user_id_and_date"

    add_index :cycle_phase_contents, [:phase, :locale], unique: true, name: "index_cycle_phase_contents_on_phase_and_locale"

    # 5. Make streak user_id unique (has_one relationship)
    remove_index :streaks, name: "index_streaks_on_user_id"
    add_index :streaks, :user_id, unique: true, name: "index_streaks_on_user_id"
  end

  def down
    # Reverse unique index on streaks
    remove_index :streaks, name: "index_streaks_on_user_id"
    add_index :streaks, :user_id, name: "index_streaks_on_user_id"

    # Remove unique index on cycle_phase_contents
    remove_index :cycle_phase_contents, name: "index_cycle_phase_contents_on_phase_and_locale"

    # Restore superpower_logs indexes
    remove_index :superpower_logs, name: "index_superpower_logs_on_user_id_and_date"
    add_index :superpower_logs, :user_id, name: "index_superpower_logs_on_user_id"
    add_index :superpower_logs, :date, name: "index_superpower_logs_on_date"

    # Remove NOT NULL and defaults from booleans
    change_column_null :users, :onboarding_completed, true
    change_column_default :users, :onboarding_completed, nil

    change_column_null :cycle_entries, :period_start, true
    change_column_default :cycle_entries, :period_start, nil

    change_column_null :cycle_entries, :period_end, true
    change_column_default :cycle_entries, :period_end, nil

    change_column_null :reminders, :active, true
    change_column_default :reminders, :active, nil

    change_column_null :symptom_logs, :sexual_intercourse, true

    # Remove NOT NULL from date/string columns
    change_column_null :calendar_events, :date, true
    change_column_null :calendar_events, :title, true
    change_column_null :cycle_entries, :date, true
    change_column_null :cycle_phase_contents, :locale, true
    change_column_null :cycle_phase_contents, :phase, true
    change_column_null :superpower_logs, :date, true
    change_column_null :symptom_logs, :date, true

    # Restore redundant indexes
    add_index :cycle_entries, :user_id, name: "index_cycle_entries_on_user_id"
    add_index :symptom_logs, :user_id, name: "index_symptom_logs_on_user_id"
  end
end
