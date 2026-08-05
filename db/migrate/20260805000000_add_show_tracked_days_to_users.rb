class AddShowTrackedDaysToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :show_tracked_days, :boolean, default: true, null: false
  end
end
