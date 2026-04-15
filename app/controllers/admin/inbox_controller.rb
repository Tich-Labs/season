class Admin::InboxController < Admin::BaseController
  before_action :set_stats, only: [:overview, :feedback, :bugs, :support]

  def overview
    @messages = Feedback.order(created_at: :desc).limit(50)
    render "admin/inbox/index"
  end

  def feedback
    @messages = Feedback.feedback_type_feedback.order(created_at: :desc).limit(50)
    render "admin/inbox/index"
  end

  def bugs
    @messages = Feedback.feedback_type_bug_report.order(created_at: :desc).limit(50)
    render "admin/inbox/index"
  end

  def support
    @messages = Feedback.feedback_type_support.order(created_at: :desc).limit(50)
    render "admin/inbox/index"
  end

  def export_csv
    messages = case params[:filter]
    when "feedback" then Feedback.feedback_type_feedback
    when "bugs" then Feedback.feedback_type_bug_report
    when "support" then Feedback.feedback_type_support
    else Feedback
    end

    csv_data = CSV.generate(headers: true) do |csv|
      csv << ["Date", "User", "Type", "Message"]
      messages.order(created_at: :desc).each do |f|
        csv << [f.created_at.strftime("%Y-%m-%d"), f.user.email, f.type, f.message.to_s.truncate(100)]
      end
    end

    respond_to do |format|
      format.csv { send_data csv_data, filename: "inbox_#{params[:filter] || "all"}_#{Date.today}.csv" }
    end
  end

  private

  def set_stats
    @stats = {
      total: Feedback.count,
      feedback: Feedback.feedback_type_feedback.count,
      bugs: Feedback.feedback_type_bug_report.count,
      support: Feedback.feedback_type_support.count
    }
  end
end
