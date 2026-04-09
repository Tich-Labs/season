class AddMissingFieldsToSeason < ActiveRecord::Migration[8.1]
  def up
    # Users — missing fields
    add_column :users, :last_period_start, :date
    add_column :users, :contraception_type, :string, default: "none"
    add_column :users, :life_stage, :string, default: "menstrual"
    rename_column :users, :onboarding_complete, :onboarding_completed

    # Symptom logs — fix types and add missing (cravings and discharge are currently strings)
    change_column :symptom_logs, :cravings, :integer, using: "COALESCE(NULLIF(cravings, '')::integer, 0)"
    change_column :symptom_logs, :discharge, :integer, using: "COALESCE(NULLIF(discharge, '')::integer, 0)"
    add_column :symptom_logs, :energy, :integer
    add_column :symptom_logs, :pain, :integer
    add_column :symptom_logs, :sexual_intercourse, :boolean, default: false
    add_index :symptom_logs, [:user_id, :date], unique: true

    # Cycle entries — missing season name
    add_column :cycle_entries, :season_name, :string
    add_index :cycle_entries, [:user_id, :date]

    # Streaks — missing defaults
    change_column_default :streaks, :current_streak, 0
    change_column_default :streaks, :longest_streak, 0
    change_column_default :streaks, :total_flames, 0
  end

  def down
    # Streaks — restore defaults
    change_column_default :streaks, :current_streak, nil
    change_column_default :streaks, :longest_streak, nil
    change_column_default :streaks, :total_flames, nil

    # Cycle entries
    remove_index :cycle_entries, [:user_id, :date]
    remove_column :cycle_entries, :season_name

    # Symptom logs
    remove_index :symptom_logs, [:user_id, :date]
    remove_column :symptom_logs, :sexual_intercourse
    remove_column :symptom_logs, :pain
    remove_column :symptom_logs, :energy
    change_column :symptom_logs, :discharge, :string
    change_column :symptom_logs, :cravings, :string

    # Users
    rename_column :users, :onboarding_completed, :onboarding_complete
    remove_column :users, :life_stage
    remove_column :users, :contraception_type
    remove_column :users, :last_period_start
  end
end
