class AddMissingCalendarPreferencesToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :show_moonphases, :boolean, default: true
    add_column :users, :show_holidays, :boolean, default: false
    add_column :users, :show_week_numbers, :boolean, default: false
  end
end
