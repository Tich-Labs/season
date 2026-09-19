class AddIcloudEventIdToCalendarEvents < ActiveRecord::Migration[8.1]
  def change
    add_column :calendar_events, :icloud_event_id, :string
    add_index :calendar_events, :icloud_event_id
  end
end
