class AddForeignKeysToConsentRecords < ActiveRecord::Migration[8.1]
  # The create migration declared the references without foreign keys, but
  # some databases already have them. Guard each add so it is safe everywhere.
  def up
    unless foreign_key_exists?(:consent_records, :beta_testers)
      add_foreign_key :consent_records, :beta_testers
    end

    # Nullify so deleting a user (account deletion) is never blocked by the ledger.
    remove_foreign_key :consent_records, :users if foreign_key_exists?(:consent_records, :users)
    add_foreign_key :consent_records, :users, on_delete: :nullify
  end

  def down
    remove_foreign_key :consent_records, :users if foreign_key_exists?(:consent_records, :users)
    remove_foreign_key :consent_records, :beta_testers if foreign_key_exists?(:consent_records, :beta_testers)
  end
end
