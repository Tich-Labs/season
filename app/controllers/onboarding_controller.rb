class OnboardingController < ApplicationController
  before_action :authenticate_user!
  before_action :check_onboarding_complete, except: [ :show, :update ]

  def show
    @step = params[:step]&.to_i || 1
    render layout: "onboarding"
  end

  def update
    @step = params[:step]&.to_i || 1

    case @step
    when 1
      current_user.update(birthday: params[:birthday])
      redirect_to onboarding_path(step: 2)
    when 2
      current_user.update(cycle_length: params[:cycle_length].to_i)
      redirect_to onboarding_path(step: 3)
    when 3
      current_user.update(period_length: params[:period_length].to_i)
      current_user.update(onboarding_complete: true) if current_user.respond_to?(:onboarding_complete=)
      redirect_to root_path, notice: "Welcome to Season!"
    end
  rescue => e
    redirect_to onboarding_path(step: @step), alert: e.message
  end

  private

  def check_onboarding_complete
    redirect_to root_path if current_user.birthday.present? && current_user.cycle_length.present?
  end
end
