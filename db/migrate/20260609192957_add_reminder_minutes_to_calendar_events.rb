class AddReminderMinutesToCalendarEvents < ActiveRecord::Migration[8.1]
  def change
    add_column :calendar_events, :reminder_minutes, :integer
  end
end
