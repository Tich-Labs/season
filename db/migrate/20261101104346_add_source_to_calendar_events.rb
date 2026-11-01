class AddSourceToCalendarEvents < ActiveRecord::Migration[8.1]
  def up
    add_column :calendar_events, :source, :string, default: "season", null: false
    add_index :calendar_events, :source
    CalendarEvent.reset_column_information
    # Backfill any rows that might exist without default applied in odd states
    CalendarEvent.where(source: nil).update_all(source: "season")
  end

  def down
    remove_index :calendar_events, :source
    remove_column :calendar_events, :source
  end
end
