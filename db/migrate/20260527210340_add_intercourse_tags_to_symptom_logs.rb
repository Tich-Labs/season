class AddIntercourseTagsToSymptomLogs < ActiveRecord::Migration[8.1]
  def change
    add_column :symptom_logs, :intercourse_tags, :string
  end
end
