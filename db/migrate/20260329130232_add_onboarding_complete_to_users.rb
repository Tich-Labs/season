class AddOnboardingCompleteToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :onboarding_complete, :boolean
  end
end
