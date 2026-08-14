class CreateM1ChecklistChecks < ActiveRecord::Migration[8.1]
  def change
    create_table :m1_checklist_checks do |t|
      t.references :user, null: false, foreign_key: true
      t.string :item_key, null: false
      t.datetime :checked_at, null: false

      t.timestamps
    end
    add_index :m1_checklist_checks, [:user_id, :item_key], unique: true
  end
end
