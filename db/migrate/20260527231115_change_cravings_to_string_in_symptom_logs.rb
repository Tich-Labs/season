class ChangeCravingsToStringInSymptomLogs < ActiveRecord::Migration[8.1]
  def up
    change_column :symptom_logs, :cravings, :string
  end

  def down
    change_column :symptom_logs, :cravings, :integer, using: "cravings::integer"
  end
end
