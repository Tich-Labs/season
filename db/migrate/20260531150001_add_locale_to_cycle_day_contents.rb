class AddLocaleToCycleDayContents < ActiveRecord::Migration[8.1]
  def change
    add_column :cycle_day_contents, :locale, :string, default: "en", null: false
    remove_index :cycle_day_contents, [:cycle_day, :card_type] if index_exists?(:cycle_day_contents, [:cycle_day, :card_type])
    add_index :cycle_day_contents, [:cycle_day, :card_type, :locale], unique: true
  end
end
