class AddRepeatFrequencyToCalendarEvents < ActiveRecord::Migration[8.1]
  def change
    add_column :calendar_events, :repeat_frequency, :string
  end
end
