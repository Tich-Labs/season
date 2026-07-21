class AddShowCycleDayOnBandToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :show_cycle_day_on_band, :boolean, default: false
  end
end
