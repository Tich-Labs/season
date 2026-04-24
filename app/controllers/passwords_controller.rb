class PasswordsController < ApplicationController
  layout "launch"
  allow_unauthenticated_access
  skip_onboarding_requirement

  before_action :load_user_from_token, only: [:edit, :update]

  def new
  end

  def edit
  end

  def create
    email = params[:email]
    user = User.find_by(email: email)
    user&.send_reset_password_instructions

    # Always redirect to done page (don't reveal whether the email exists).
    redirect_to done_password_path
  rescue => e
    Rails.logger.error "Password reset error: #{e.class} - #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    redirect_to password_error_contact_path, alert: t(".unable_to_send", default: "We were unable to send the reset email. Please contact support.")
  end

  def update
    if @user.update(password: params[:password], password_confirmation: params[:password_confirmation])
      redirect_to new_session_path, notice: t(".password_updated_notice")
    else
      render :edit, status: :unprocessable_content
    end
  end

  def done
  end

  def error_already_reset
  end

  def error_link_expired
  end

  def error_wrong_email
  end

  def error_inbox_full
  end

  def error_contact
  end

  private

  def load_user_from_token
    @user = User.with_reset_password_token(params[:reset_password_token])
    redirect_to password_error_link_expired_path if @user.nil?
  end
end
