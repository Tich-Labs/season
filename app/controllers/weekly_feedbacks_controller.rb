class WeeklyFeedbacksController < ApplicationController
  before_action :authenticate_user

  TOTAL_WEEKS = 8

  # Feedback hub — lists all 8 weeks, colour-coded by status (completed /
  # current / locked), per Figma node 12178:6273 ("Feedback geben").
  def index
    @current_week = current_user.current_feedback_week
    completed_weeks = current_user.weekly_feedback_responses
      .where(week_number: 1..TOTAL_WEEKS).distinct.pluck(:week_number).to_set

    @weeks = (1..TOTAL_WEEKS).map do |week|
      status =
        if completed_weeks.include?(week)
          :completed
        elsif week == @current_week
          :current
        else
          :locked
        end
      {number: week, status: status}
    end
  end

  # Per-week wizard — one question at a time, swipeable, per Figma nodes
  # 12178:6399 (Multiple Choice) / 12178:7300 (Yes/No) / 12178:7283 (Text only).
  def show
    @week = params[:week].to_i
    current_week = current_user.current_feedback_week

    # Only the current week or an already-completed past week can be
    # opened — future weeks are locked in the Figma hub and have no
    # questions assigned to them yet anyway.
    already_completed = current_user.weekly_feedback_responses.exists?(week_number: @week)
    unless @week == current_week || already_completed
      redirect_to weekly_feedback_path, alert: t(".locked", default: "That week isn't available yet.")
      return
    end

    @already_completed = already_completed
    @questions = WeeklyFeedbackQuestion.for_week(@week)
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
