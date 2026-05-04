class AddMissingCalendarPreferencesToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :show_moonphases, :boolean
    add_column :users, :show_holidays, :boolean
    add_column :users, :show_week_numbers, :boolean
  end
end
