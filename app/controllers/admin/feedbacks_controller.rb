class Admin::FeedbacksController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin

  def index
    @feedbacks = Feedback.order(created_at: :desc)
    @feedbacks = @feedbacks.feedback_type_feedback if params[:type] == "feedback"
    @feedbacks = @feedbacks.feedback_type_bug_report if params[:type] == "bug_report"
    @feedbacks = @feedbacks.feedback_type_support if params[:type] == "support"
    @feedbacks = @feedbacks.page(params[:page]).per(20)
  end

  def export_csv
    feedbacks = Feedback.order(created_at: :desc)

    csv_data = CSV.generate(headers: true) do |csv|
      csv << ["ID", "User Email", "Type", "Message", "Attachment", "Created At"]
      feedbacks.each do |f|
        csv << [f.id, f.user.email, f.feedback_type, f.message, f.attachment, f.created_at.strftime("%Y-%m-%d %H:%M")]
      end
    end

    respond_to do |format|
      format.csv { send_data csv_data, filename: "feedbacks_#{Time.zone.today}.csv" }
    end
  end

  private

  def require_admin
    # TODO: Add admin role check when user roles are implemented
    # For now, allow any logged-in user (replace with actual admin check)
  end
end
