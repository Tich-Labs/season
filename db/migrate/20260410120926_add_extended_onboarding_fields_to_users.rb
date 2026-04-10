class AddExtendedOnboardingFieldsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :has_regular_cycle, :boolean
    add_column :users, :uses_hormonal_birth_control, :boolean
    add_column :users, :birth_control_reminder, :boolean
    add_column :users, :food_preference, :string
    add_column :users, :cycle_stage_reminder, :boolean
  end
end
