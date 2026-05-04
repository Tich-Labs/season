class AddDefaultsToCalendarPreferences < ActiveRecord::Migration[8.1]
  def up
    change_column :users, :show_appointments, :boolean, default: true
    change_column :users, :show_cycledays, :boolean, default: true
    change_column :users, :show_moonphases, :boolean, default: true
    change_column :users, :show_holidays, :boolean, default: false
    change_column :users, :show_week_numbers, :boolean, default: false
  end

  def down
    change_column :users, :show_appointments, :boolean, default: nil
    change_column :users, :show_cycledays, :boolean, default: nil
    change_column :users, :show_moonphases, :boolean, default: nil
    change_column :users, :show_holidays, :boolean, default: nil
    change_column :users, :show_week_numbers, :boolean, default: nil
  end
end
