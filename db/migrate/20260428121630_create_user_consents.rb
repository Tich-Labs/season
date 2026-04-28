class CreateUserConsents < ActiveRecord::Migration[8.1]
  def change
    create_table :user_consents do |t|
      t.references :user, null: false, foreign_key: true
      t.string :consent_type, null: false
      t.datetime :granted_at, null: false
      t.datetime :revoked_at
      t.string :ip_address
      t.string :user_agent
      t.text :metadata

      t.timestamps
    end

    add_index :user_consents, [:user_id, :consent_type], unique: true, where: "revoked_at IS NULL"
    add_index :user_consents, :consent_type
    add_index :user_consents, :granted_at
  end
end
