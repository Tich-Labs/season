class AddAttachmentToFeedbacks < ActiveRecord::Migration[8.0]
  def change
    add_column :feedbacks, :attachment, :string # URL to screenshot/audio file
    add_column :feedbacks, :active, :boolean, default: true, null: false
  end
end
