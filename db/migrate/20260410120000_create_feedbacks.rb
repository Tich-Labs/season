class CreateFeedbacks < ActiveRecord::Migration[8.0]
  def change
    create_table :feedbacks do |t|
      t.references :user, null: false, foreign_key: true
      t.string :type, null: false, default: "feedback" # feedback, bug_report
      t.text :message, null: false
      t.string :screenshot_url

      t.timestamps
    end
  end
end
