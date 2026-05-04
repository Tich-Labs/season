class AddCalendarPreferencesToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :show_appointments, :boolean, default: true
    add_column :users, :show_cycledays, :boolean, default: true
    add_column :users, :show_phases, :boolean, default: true
    add_column :users, :show_prediction, :boolean, default: true
    add_column :users, :show_forecast, :boolean, default: true
    add_column :users, :show_superpowers, :boolean, default: true
    add_column :users, :week_start_day, :string, default: "monday"
    add_column :users, :hide_past_events, :boolean, default: false
  end
end
end
