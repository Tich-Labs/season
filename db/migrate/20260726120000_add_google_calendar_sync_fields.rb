class AddGoogleCalendarSyncFields < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :google_calendar_email, :string
    add_column :calendar_events, :google_event_id, :string
    add_index :calendar_events, :google_event_id
  end
end
