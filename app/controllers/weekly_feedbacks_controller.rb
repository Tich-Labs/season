class WeeklyFeedbacksController < ApplicationController
  before_action :authenticate_user

  def show
    week = current_user.current_feedback_week
    unless week
      render json: {questions: [], week: nil, message: "No active feedback week"}
      return
    end

    questions = WeeklyFeedbackQuestion.for_week(week)
    already_completed = current_user.weekly_feedback_responses
      .exists?(week_number: week)

    render json: {
      week: week,
      already_completed: already_completed,
      questions: questions.map { |q|
        {
          id: q.id,
          question_text: q.question_text,
          question_type: q.question_type,
          options: q.options
        }
      }
    }
  end

  def submit
    week = current_user.current_feedback_week
    unless week
      render json: {error: "No active feedback week"}, status: :unprocessable_content
      return
    end

    batch_id = SecureRandom.uuid
    responses = []

    WeeklyFeedbackQuestion.for_week(week).each do |question|
      answer = params[:answers]&.dig(question.id.to_s)
      next if answer.blank?

      response = current_user.weekly_feedback_responses.build(
        weekly_feedback_question: question,
        week_number: week,
        submission_batch_id: batch_id
      )

      case question.question_type
      when "multiple_choice"
        response.selected_option = answer
      when "yes_no_with_input"
        parts = answer.split("|", 2)
        response.selected_option = parts[0]
        response.response_text = parts[1] if parts[1].present?
      when "text_only"
        response.response_text = answer
      end

      response.save!
      responses << response
    end

    render json: {success: true, week: week, batch_id: batch_id}
  rescue ActiveRecord::RecordInvalid => e
    render json: {error: e.message}, status: :unprocessable_content
  end
end
