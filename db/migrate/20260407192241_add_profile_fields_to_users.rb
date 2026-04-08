class AddProfileFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :cycle_days, :integer
    add_column :users, :last_menstruation, :string
  end
end
