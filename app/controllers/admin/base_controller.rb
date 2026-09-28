class Admin::BaseController < ApplicationController
  layout "admin"
  skip_onboarding_requirement
  allow_pin_bypass
  before_action :require_admin, :set_inbox_stats

  private

  def require_admin
    unless authenticated?
      redirect_to admin_login_path
      return
    end
    redirect_to root_path unless current_user.admin?
  end

  def set_inbox_stats
    inbox = Feedback.active
    @stats = {
      total: inbox.count,
      feedback: inbox.feedback_type_feedback.count,
      bugs: inbox.feedback_type_bug_report.count,
      support: inbox.feedback_type_support.count,
      archived: Feedback.archived.count
    }
  end
end
