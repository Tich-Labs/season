class AddSecretTesterToUsers < ActiveRecord::Migration[8.1]
  # Everyone who signed up from 20 Sep 2026 (UTC) onwards is a secret tester.
  SECRET_TESTER_CUTOFF = "2026-09-20 00:00:00"

  def up
    add_column :users, :secret_tester, :boolean, default: false, null: false
    execute "UPDATE users SET secret_tester = TRUE WHERE created_at >= '#{SECRET_TESTER_CUTOFF}'"
  end

  def down
    remove_column :users, :secret_tester
  end
end
