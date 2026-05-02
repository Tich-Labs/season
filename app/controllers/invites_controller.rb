class InvitesController < ApplicationController
  layout "launch"
  allow_unauthenticated_access

  def show
    @user = User.find_by!(invite_token: params[:token])

    # Check if invite already used
    if @user.invite_accepted_at.present?
      redirect_to new_session_path, alert: t(".already_used")
      return
    end

    # Check if invite token has expired (7 days)
    if @user.invite_token_expires_at&.past?
      @user.update(invite_token: nil)
      redirect_to root_path, alert: t(".token_expired")
      return
    end

    render template: "onboarding/invite"
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: t(".invalid_link")
  end

  def update
    @user = User.find_by!(invite_token: params[:token])

    # Check if invite token has expired
    if @user.invite_token_expires_at&.past?
      @user.update(invite_token: nil)
      redirect_to root_path, alert: t(".token_expired")
      return
    end

    if @user.update(
      password: params[:password],
      password_confirmation: params[:password],
      invite_accepted_at: Time.current,
      invite_token: nil
    )
      login(@user)
      redirect_to onboarding_path(1), notice: t(".welcome")
    else
      render template: "onboarding/invite", status: :unprocessable_content
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: t(".invalid_link")
  end
end
