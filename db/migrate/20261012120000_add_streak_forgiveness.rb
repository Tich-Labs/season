class AddStreakForgiveness < ActiveRecord::Migration[8.1]
  # Forgiveness tracking so a single missed day doesn't wipe out a long streak.
  #   grace_week — Monday of the calendar week the most recent grace was spent in
  #   grace_used — how many free (non-rest) missed days were forgiven that week
  def change
    add_column :streaks, :grace_week, :date
    add_column :streaks, :grace_used, :integer, default: 0, null: false
  end
end
