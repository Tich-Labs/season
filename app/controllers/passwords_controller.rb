class PasswordsController < ApplicationController
  layout "launch"
  allow_unauthenticated_access
  skip_onboarding_requirement

  def new
  end

  def edit
    @user = User.find_by_token_for(:password_reset, params[:token])
    if @user.nil?
      redirect_to password_error_already_reset_path
    end
  end

  def create
    @user = User.find_by(email: params[:email])
    if @user.present?
      @user.generate_token_for(:password_reset)
      redirect_to done_password_path
    else
      redirect_to password_error_wrong_email_path
    end
  end

  def update
    @user = User.find_by_token_for(:password_reset, params[:token])
    if @user&.update(password: params[:password])
      redirect_to new_session_path, notice: t(".password_updated_notice")
    else
      redirect_to password_error_contact_path, alert: t(".unable_to_update")
    end
  end

  def done
  end

  def error_already_reset
  end

  def error_wrong_email
  end

  def error_inbox_full
  end

  def error_contact
  end
end
