class AddEndDateToCalendarEvents < ActiveRecord::Migration[8.1]
  def change
    add_column :calendar_events, :end_date, :date
  end
end
