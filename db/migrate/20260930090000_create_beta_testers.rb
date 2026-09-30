class CreateBetaTesters < ActiveRecord::Migration[8.1]
  def change
    create_table :beta_testers do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :platform, null: false
      t.boolean :beta_consent, null: false, default: false
      t.string :status, null: false, default: "registered"

      t.timestamps
    end

    add_index :beta_testers, :email, unique: true
    add_index :beta_testers, :platform
    add_index :beta_testers, :status
  end
end
