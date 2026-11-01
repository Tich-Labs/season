class AddSourceToCalendarEvents < ActiveRecord::Migration[8.1]
  def change
    # The default fills existing rows with "season" on PostgreSQL, so no backfill is needed.
    add_column :calendar_events, :source, :string, default: "season", null: false
    add_index :calendar_events, :source
  end
end
