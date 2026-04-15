class Admin::BaseController < ApplicationController
  layout "admin"
  before_action :require_admin, :set_inbox_stats

  private

  def require_admin
    redirect_to root_path unless authenticated? && current_user.admin?
  end

  def set_inbox_stats
    @stats = {
      total: Feedback.count,
      feedback: Feedback.feedback_type_feedback.count,
      bugs: Feedback.feedback_type_bug_report.count,
      support: Feedback.feedback_type_support.count
    }
  end
end
