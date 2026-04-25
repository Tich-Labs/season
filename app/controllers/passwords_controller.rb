class PasswordsController < ApplicationController
  layout "launch"
  allow_unauthenticated_access
  skip_onboarding_requirement

  LOG_PREFIX = "[PASSWORD RESET]"

  before_action :load_user_from_token, only: [:edit, :update]

  def new
  end

  def edit
  end

  def create
    email = params[:email].to_s.strip.downcase
    user = User.find_by(email: email)
    Rails.logger.info "#{LOG_PREFIX} Requested for email=#{email.inspect} user_found=#{user.present?}"
    user&.send_reset_password_instructions
    Rails.logger.info "#{LOG_PREFIX} Instructions queued for email=#{email.inspect}"

    # Always redirect to done page (don't reveal whether the email exists).
    redirect_to done_password_path
  rescue => e
    Rails.logger.error "#{LOG_PREFIX} FAILED email=#{email.inspect} error=#{e.class} message=#{e.message}"
    Rails.logger.error e.backtrace.first(10).join("\n")
    Sentry.capture_exception(e) if defined?(Sentry)
    redirect_to password_error_contact_path, alert: t(".unable_to_send", default: "Unable to send reset email. Please contact support.")
  end

  def update
    @user.skip_reconfirmation!
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
