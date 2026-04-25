class SettingsController < ApplicationController
  before_action :require_onboarding_completed

  def edit
    @user = current_user
  end

  def profile
    @user = current_user
  end

  SubscriptionData = Struct.new(:plan, :payment_method)
  CalendarSettings = Struct.new(:appointments, :cycledays, :tracking_reminder, :moonphases,
    :holidays, :kalenderwochen, :day_of_week, :keep_timezone)
  NotificationSettings = Struct.new(:cycle_reminder, :period_prediction, :ovulation_alert,
    :appointment_reminder, :newsletter, :push_notifications, :email_notifications, :reminder_time)

  def subscriptions
    @subscription = SubscriptionData.new(current_user.plan || "Freemium", "none")
  end

  def calendar
    @settings = CalendarSettings.new(true, false, true, true, true, false, "monday", true)
  end

  def notifications
    @notifications = NotificationSettings.new(true, true, true, false, true, true, true, "09:00")
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
      unless @user.valid_password?(params[:current_password].to_s)
        redirect_to profile_settings_path, alert: t(".invalid_password", default: "Current password is incorrect.")
        return
      end
      @user.update(email: params[:email])
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

  def notification_morning
    @user = current_user
  end

  def notification_period
    @user = current_user
  end

  def notification_birth_control
    @user = current_user
    @contraception = @user.contraception_type.presence || "none"
  end

  def update_notifications
    notification_keys = [:cycle_reminder, :period_prediction, :ovulation_alert, :push_notifications, :email_notifications, :newsletter]
    updates = {}
    notification_keys.each do |key|
      updates[key] = params[key] == "true" || params[key] == true
    end
    current_user.notification_settings&.update(updates)
    render json: {success: true}
  end

  private

  def user_params
    params.expect(user: [:name, :language, :cycle_length, :period_length, :contraception_type, :life_stage])
  end
end
