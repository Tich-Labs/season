class AddOauthUidsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :google_uid, :string
    add_column :users, :facebook_uid, :string
    add_column :users, :apple_uid, :string
  end
end
