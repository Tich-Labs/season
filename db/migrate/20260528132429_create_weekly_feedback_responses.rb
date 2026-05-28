class CreateWeeklyFeedbackResponses < ActiveRecord::Migration[8.1]
  def change
    create_table :weekly_feedback_responses do |t|
      t.references :user, null: false, foreign_key: true
      t.references :weekly_feedback_question, null: false, foreign_key: true
      t.string :selected_option
      t.text :response_text
      t.integer :week_number, null: false
      t.string :submission_batch_id, null: false

      t.timestamps
    end

    add_index :weekly_feedback_responses, :submission_batch_id
    add_index :weekly_feedback_responses, [:user_id, :week_number]
  end
end
