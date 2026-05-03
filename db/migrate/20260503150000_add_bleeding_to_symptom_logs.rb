class AddBleedingToSymptomLogs < ActiveRecord::Migration[7.2]
  def change
    add_column :symptom_logs, :bleeding, :string, default: nil
  end
end
