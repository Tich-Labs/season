class CreateCycleDayContents < ActiveRecord::Migration[8.1]
  def change
    create_table :cycle_day_contents do |t|
      t.integer :cycle_day, null: false
      t.string :card_type, null: false
      t.text :short_text
      t.text :long_text
      t.jsonb :food_items

      t.timestamps
    end

    add_index :cycle_day_contents, [:cycle_day, :card_type], unique: true
  end
end
