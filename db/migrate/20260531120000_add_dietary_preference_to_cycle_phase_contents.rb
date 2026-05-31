class AddDietaryPreferenceToCyclePhaseContents < ActiveRecord::Migration[8.1]
  def change
    add_column :cycle_phase_contents, :dietary_preference, :string, default: "", null: false

    remove_index :cycle_phase_contents, column: [:phase, :locale], unique: true
    add_index :cycle_phase_contents, [:phase, :locale, :dietary_preference],
      unique: true,
      name: "idx_cycle_phase_contents_on_phase_locale_dietary"
  end
end
