class CreateNotifications < ActiveRecord::Migration[8.1]
  def change
    create_table :notifications do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.string :notification_type, null: false, default: "info"
      t.datetime :read_at
      t.timestamps

      t.index [:user_id, :created_at], name: "index_notifications_on_user_id_and_created_at"
      t.index [:user_id, :read_at], name: "index_notifications_on_user_id_and_read_at"
    end
  end
end
