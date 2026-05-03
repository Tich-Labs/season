class AddMoodTextToSymptomLogs < ActiveRecord::Migration[8.1]
  def change
    add_column :symptom_logs, :mood_text, :text
  end
end
