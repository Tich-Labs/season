class CreateWebauthnCredentials < ActiveRecord::Migration[8.1]
  def change
    create_table :webauthn_credentials do |t|
      t.references :user, null: false, foreign_key: true
      t.string :credential_id, null: false
      t.text :public_key, null: false
      t.string :label, default: "Default"
      t.bigint :sign_count, default: 0, null: false
      t.timestamps
    end
    add_index :webauthn_credentials, :credential_id, unique: true
  end
end
