class AddGuestsToCalendarEvents < ActiveRecord::Migration[8.1]
  def change
    add_column :calendar_events, :guests, :text
  end
end
