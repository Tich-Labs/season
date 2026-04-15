class RemoveDuplicateUserColumns < ActiveRecord::Migration[8.1]
  # Removes legacy columns superseded by canonical equivalents:
  #   locale (string)           → language    (used everywhere; language has NOT NULL default)
  #   age (integer)             → birthday    (birthday is source of truth; age is computed)
  #   last_menstruation (string)→ last_period_start (date, used by all business logic)
  #   cycle_days (integer)      → cycle_length (cycle_length is used everywhere)
  def up
    remove_column :users, :locale, :string
    remove_column :users, :age, :integer
    remove_column :users, :last_menstruation, :string
    remove_column :users, :cycle_days, :integer
  end

  def down
    add_column :users, :locale, :string
    add_column :users, :age, :integer
    add_column :users, :last_menstruation, :string
    add_column :users, :cycle_days, :integer
  end
end
