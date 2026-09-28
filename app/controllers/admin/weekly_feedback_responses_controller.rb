class Admin::WeeklyFeedbackResponsesController < Admin::BaseController
  def index
    @responses = WeeklyFeedbackResponse.includes(:user, :weekly_feedback_question)
      .order(created_at: :desc)
      .limit(200)
  end

  def export_csv
    responses = WeeklyFeedbackResponse.includes(:user, :weekly_feedback_question)
      .order(created_at: :desc)

    csv_data = CSV.generate(headers: true) do |csv|
      csv << ["Date", "User ID", "Week", "Question", "Type", "Answer", "Details"]

      responses.find_each do |r|
        csv << [
          r.created_at.strftime("%Y-%m-%d %H:%M"),
          r.user.public_id,
          "Week #{r.week_number}",
          r.weekly_feedback_question.question_text,
          r.weekly_feedback_question.question_type,
          r.selected_option,
          r.response_text
        ]
      end
    end

    send_data csv_data, filename: "weekly_feedback_responses_#{Time.zone.today}.csv", type: "text/csv"
  end
end
