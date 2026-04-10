class BugReportController < ApplicationController
  before_action :authenticate_user!

  def new
  end

  def create
    # TODO: Store bug report in database or send to external service
    # For now, just redirect back with success message
    redirect_to user_root_path, notice: t("bug_reports.create.thank_you")
  end
end
