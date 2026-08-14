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
    email = params[:email].to_s.strip.downcase
    user = User.find_by(email: email)

    # A known-recent bounce on this address is worth surfacing immediately
    # instead of quietly resending into the same dead end -- it's a narrow
    # deviation from the "always redirect to done, don't reveal whether the
    # email exists" rule below (an attacker now learns "this address exists
    # and bounced recently"), accepted deliberately for this case since a
    # bounce implies the user themselves already tried this address once.
    if user && (bounce = user.recent_email_bounce_type)
      user.clear_email_bounce! # consumed -- don't keep blocking their next attempt once shown
      redirect_to (bounce == "inbox_full") ? password_error_inbox_full_path : password_error_wrong_email_path
      return
    end

    user&.send_reset_password_instructions

    # Always redirect to done page (don't reveal whether the email exists).
    redirect_to done_password_path
  rescue => e
    Rails.logger.error("[PASSWORD RESET] Failed for #{email.inspect}: #{e.class} #{e.message}")
    Sentry.capture_exception(e) if defined?(Sentry)
    redirect_to password_error_contact_path, alert: t(".unable_to_send", default: "Unable to send reset email. Please contact support.")
  end

  def update
    if @user.update(password: params[:password], password_confirmation: params[:password_confirmation])
      login @user
      redirect_to after_sign_in_path, notice: t(".password_updated_notice")
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
