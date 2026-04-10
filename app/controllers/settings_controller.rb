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

  def notifications
    @notifications = OpenStruct.new(
      cycle_reminder: true,
      period_prediction: true,
      ovulation_alert: true,
      appointment_reminder: false,
      newsletter: true,
      push_notifications: true,
      email_notifications: true,
      reminder_time: "09:00"
    )
  end

  def update_avatar
    @user = current_user
    if params[:avatar].is_a?(ActionDispatch::Http::UploadedFile)
      @user.avatar.attach(params[:avatar])
    elsif params[:avatar_url].present? && params[:avatar_url].starts_with?("http")
      # URL fallback
      @user.update(avatar_url: params[:avatar_url])
    end
    redirect_to profile_settings_path
  end

  def update_profile
    @user = current_user
    if params[:email].present? && params[:email] != @user.email
      @user.update(email: params[:email])
      @user.send_confirmation_instructions
      redirect_to profile_settings_path, notice: t(".confirmation_sent")
    elsif params[:name].present? || params[:cycle_length].present? || params[:period_length].present?
      updates = {}
      updates[:name] = params[:name] if params[:name].present?
      updates[:cycle_length] = params[:cycle_length].to_i if params[:cycle_length].present?
      updates[:period_length] = params[:period_length].to_i if params[:period_length].present?
      @user.update(updates) if updates.any?
      redirect_to profile_settings_path, notice: t(".saved")
    else
      redirect_to profile_settings_path
    end
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
