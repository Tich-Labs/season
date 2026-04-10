require "ostruct"

class SettingsController < ApplicationController
  before_action :require_onboarding_completed

  def edit
    @user = current_user
  end

  def profile
    @user = current_user
  end

  def subscriptions
    @subscription = OpenStruct.new(
      plan: current_user.plan || "Freemium",
      payment_method: "none"
    )
  end

  def calendar
    @settings = OpenStruct.new(
      appointments: true,
      cycledays: false,
      tracking_reminder: true,
      moonphases: true,
      holidays: true,
      kalenderwochen: false,
      day_of_week: "monday",
      keep_timezone: true
    )
  end

  def update
    @user = current_user
    if @user&.update(user_params)
      redirect_to edit_settings_path, notice: t(".saved")
    else
      render :edit, status: :unprocessable_content
    end
  end

  private

  def user_params
    params.expect(user: [:name, :language, :cycle_length, :period_length, :contraception_type, :life_stage])
  end
end
