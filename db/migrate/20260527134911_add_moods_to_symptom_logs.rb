class AddMoodsToSymptomLogs < ActiveRecord::Migration[8.1]
  def up
    add_column :symptom_logs, :moods, :jsonb, {default: [], null: false}

    SymptomLog.where.not(mood_text: [nil, ""]).find_each do |log|
      log.update_column(:moods, [log.mood_text]) # rubocop:disable Rails/SkipsModelValidations
    end
  end

  def down
    SymptomLog.where.not(moods: []).find_each do |log|
      log.update_column(:mood_text, log.moods.first) # rubocop:disable Rails/SkipsModelValidations
    end
    remove_column :symptom_logs, :moods
  end
end
