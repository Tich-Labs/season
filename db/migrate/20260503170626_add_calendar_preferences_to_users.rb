class AddCalendarPreferencesToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :show_appointments, :boolean
    add_column :users, :show_cycledays, :boolean
    add_column :users, :show_phases, :boolean
    add_column :users, :show_prediction, :boolean
    add_column :users, :show_forecast, :boolean
    add_column :users, :show_superpowers, :boolean
    add_column :users, :week_start_day, :string
    add_column :users, :hide_past_events, :boolean
  end
end
