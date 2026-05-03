class AddMentalSymptomsToSymptomLogs < ActiveRecord::Migration[7.2]
  def change
    add_column :symptom_logs, :mental_symptoms, :jsonb, default: {}, null: false
  end
end
