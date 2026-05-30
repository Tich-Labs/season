class AddLastPeriodEndToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :last_period_end, :date
  end
end
