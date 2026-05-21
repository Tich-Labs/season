class AddNativeAuthTokenToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :native_auth_token, :string
    add_index :users, :native_auth_token, unique: true
  end
end
