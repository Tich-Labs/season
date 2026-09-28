class AddArchiveAuditToFeedbacks < ActiveRecord::Migration[8.1]
  def change
    add_column :feedbacks, :archived_at, :datetime
    add_reference :feedbacks, :archived_by, foreign_key: {to_table: :users, on_delete: :nullify}
  end
end
