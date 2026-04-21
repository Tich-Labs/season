class AddPublicIdToUsers < ActiveRecord::Migration[8.1]
  def change
    # pgcrypto provides gen_random_uuid() — needed for the DB-level default.
    # Enabling it here is idempotent; safe to run on Render where it may already exist.
    enable_extension "pgcrypto" unless extension_enabled?("pgcrypto")

    # Each existing row gets a unique UUID generated at migration time.
    # New rows get one automatically from the DB default — no app code required.
    add_column :users, :public_id, :uuid,
      default: -> { "gen_random_uuid()" },
      null: false

    add_index :users, :public_id, unique: true
  end
end
