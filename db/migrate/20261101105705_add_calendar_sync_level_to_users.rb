class AddCalendarSyncLevelToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :calendar_sync_level, :string, default: "off", null: false
    add_index :users, :calendar_sync_level
  end
end
