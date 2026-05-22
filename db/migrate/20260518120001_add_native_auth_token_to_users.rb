class AddNativeAuthTokenToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :native_auth_token, :string unless column_exists?(:users, :native_auth_token)
    add_column :users, :native_auth_token_created_at, :datetime unless column_exists?(:users, :native_auth_token_created_at)
    add_index :users, :native_auth_token, unique: true unless index_exists?(:users, :native_auth_token)
  end
end
