class AddAdvanceDaysToReminders < ActiveRecord::Migration[8.1]
  def change
    add_column :reminders, :advance_days, :integer
  end
end
