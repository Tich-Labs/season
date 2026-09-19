class AddIcloudCalendarFieldsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :icloud_email, :string
    add_column :users, :icloud_app_password, :string
  end
end
