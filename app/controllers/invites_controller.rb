class InvitesController < ApplicationController
  layout "launch"
  allow_unauthenticated_access

  def show
    @user = User.find_by!(invite_token: params[:token])
    if @user.invite_accepted_at.present?
      redirect_to new_session_path, alert: "This invite has already been used."
      return
    end
    render template: "onboarding/invite"
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: "Invalid invite link."
  end

  def update
    @user = User.find_by!(invite_token: params[:token])
    if @user.update(
      password: params[:password],
      password_confirmation: params[:password],
      invite_accepted_at: Time.current,
      invite_token: nil
    )
      login(@user)
      redirect_to onboarding_path(1), notice: "Welcome to Season!"
    else
      render template: "onboarding/invite", status: :unprocessable_content
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: "Invalid invite link."
  end
end
