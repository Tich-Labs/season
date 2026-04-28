class SettingsController < ApplicationController
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
    @reminder = current_user.reminders.find_or_initialize_by(reminder_type: "morning")
  end

  def notification_period
    @start_reminder = current_user.reminders.find_or_initialize_by(reminder_type: "period_start")
    @end_reminder = current_user.reminders.find_or_initialize_by(reminder_type: "period_end")
  end

  def notification_birth_control
    @contraception = current_user.contraception_type.presence || "none"
    @reminder = current_user.reminders.find_or_initialize_by(reminder_type: "pill")
  end

  def save_morning_reminder
    save_single_reminder("morning", "09:00", notification_morning_settings_path, "morning_saved")
  end

  def save_period_reminder
    enabled = params[:enabled] == "1"
    advance = params[:advance_days].to_i.clamp(1, 7)
    ApplicationRecord.transaction do
      %w[period_start period_end].each do |type|
        r = current_user.reminders.find_or_initialize_by(reminder_type: type)
        r.active = enabled
        r.time = params["#{type}_time"].presence || "08:00"
        r.advance_days = advance
        r.save!
      end
    end
    redirect_to notification_period_settings_path, notice: t("settings.reminders.period_saved")
  end

  def save_birth_control_reminder
    save_single_reminder("pill", "21:00", notification_birth_control_settings_path, "birth_control_saved")
  end

  def consent
    @consent_types = UserConsent::VALID_CONSENT_TYPES
  end

  FORM_CONSENT_TYPES = %w[health_data_processing symptom_tracking cycle_tracking menstrual_data].freeze

  def save_consents
    checked = (params[:consents]&.keys || []) & FORM_CONSENT_TYPES

    FORM_CONSENT_TYPES.each do |type|
      record = current_user.user_consents.find_or_initialize_by(consent_type: type)
      if checked.include?(type)
        record.grant!(request.remote_ip, request.user_agent)
      elsif record.persisted? && record.active?
        record.revoke!(request.remote_ip, request.user_agent)
      end
    end

    redirect_to user_root_path, notice: t("consent.saved")
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

  def save_single_reminder(type, default_time, redirect_path, notice_key)
    r = current_user.reminders.find_or_initialize_by(reminder_type: type)
    r.active = params[:enabled] == "1"
    r.time = params[:time].presence || default_time
    r.save!
    redirect_to redirect_path, notice: t("settings.reminders.#{notice_key}")
  end

  def user_params
    params.expect(user: [:name, :language, :cycle_length, :period_length, :contraception_type, :life_stage])
  end
end
