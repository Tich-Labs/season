class PasswordsController < ApplicationController
  layout "launch"
  allow_unauthenticated_access only: [:new, :create, :edit, :update]

  def new
  end

  def create
    @user = User.find_by(email: params[:email])
    if @user
      @user.generate_token_for(:password_reset)
      # PasswordMailer.reset(@user, token).deliver_later
    end
    redirect_to password_done_path
  end

  def edit
    @user = User.find_by_token_for(:password_reset, params[:token])
    redirect_to new_session_path unless @user
  end

  def update
    @user = User.find_by_token_for(:password_reset, params[:token])
    if @user&.update(password: params[:password])
      redirect_to new_session_path, notice: "Password updated"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def done
  end

  def error_already_reset
  end

  def error_inbox_full
  end

  def error_wrong_email
  end

  def error_contact
  end
end
