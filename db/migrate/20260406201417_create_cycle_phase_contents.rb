class CreateCyclePhaseContents < ActiveRecord::Migration[8.0]
  def change
    unless table_exists?(:cycle_phase_contents)
      create_table :cycle_phase_contents do |t|
        t.string :phase
        t.string :locale
        t.string :season_name
        t.text :superpower_text
        t.text :mood_text
        t.text :take_care_text
        t.text :sport_text
        t.text :nutrition_text

        t.timestamps
      end
    end
  end
end
