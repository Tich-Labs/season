class CreateWeeklyFeedbackQuestions < ActiveRecord::Migration[8.1]
  def change
    create_table :weekly_feedback_questions do |t|
      t.integer :week_number, null: false
      t.string :question_type, null: false
      t.text :question_text, null: false
      t.jsonb :options, default: []
      t.integer :position, null: false, default: 0
      t.boolean :active, null: false, default: true

      t.timestamps
    end

    add_index :weekly_feedback_questions, [:week_number, :position]
  end
end
