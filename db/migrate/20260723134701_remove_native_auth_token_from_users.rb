class RemoveNativeAuthTokenFromUsers < ActiveRecord::Migration[8.1]
  def change
    remove_index :users, column: :native_auth_token, if_exists: true
    remove_column :users, :native_auth_token, if_exists: true
    remove_column :users, :native_auth_token_created_at, if_exists: true
  end
end
