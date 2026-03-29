class AddProfileFieldsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :birthday, :date
    add_column :users, :cycle_length, :integer
    add_column :users, :period_length, :integer
  end
end
