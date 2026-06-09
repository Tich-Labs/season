class AddLocationToCalendarEvents < ActiveRecord::Migration[8.0]
  def change
    add_column :calendar_events, :location, :string
  end
end
