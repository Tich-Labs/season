class AddOnboardingFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :locale, :string unless column_exists?(:users, :locale)
  end
end
