class AccountController < ApplicationController
  layout "application"
  before_action :authenticate_user

  def show
    @user = current_user
  end

  def destroy
    @user = current_user

    # Destroy all associated data (dependent: :destroy already configured in User model)
    # This deletes: cycle_entries, calendar_events, symptom_logs, superpower_logs,
    # reminders, feedbacks, streak, avatar
    @user.destroy!

    # Also purge any ActiveStorage attachments
    @user.avatar&.purge

    # Log out the user
    logout

    redirect_to root_path, notice: t(".account_deleted")
  end
end
