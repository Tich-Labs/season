class AddPhysicalSymptomsToSymptomLogs < ActiveRecord::Migration[7.2]
  def change
    add_column :symptom_logs, :physical_symptoms, :jsonb, default: {}, null: false
  end
end
