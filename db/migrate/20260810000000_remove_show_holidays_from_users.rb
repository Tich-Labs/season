class RemoveShowHolidaysFromUsers < ActiveRecord::Migration[8.1]
  def change
    remove_column :users, :show_holidays, :boolean
  end
end
