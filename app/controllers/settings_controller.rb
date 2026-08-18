class SettingsController < ApplicationController
  def edit
    @user = current_user
  end

  def profile
    @user = current_user
  end

  SubscriptionData = Struct.new(:plan, :payment_method)
  CalendarSettings = Struct.new(:appointments, :tracking_reminder, :moonphases,
    :holidays, :kalenderwochen, :day_of_week, :keep_timezone)
  NotificationSettings = Struct.new(:cycle_reminder, :period_prediction, :ovulation_alert,
    :appointment_reminder, :newsletter, :push_notifications, :email_notifications, :reminder_time)

  def subscriptions
    @subscription = SubscriptionData.new(current_user.plan || "Freemium", "none")
  end

  def calendar
    @user = current_user
  end

  def update_calendar
    @user = current_user
    preferences = {
      show_appointments: params[:show_appointments] == "1",
      show_tracked_days: params[:show_tracked_days] == "1",
      show_moonphases: params[:show_moonphases] == "1",
      show_week_numbers: params[:show_week_numbers] == "1",
      show_cycle_day_on_band: params[:show_cycle_day_on_band] == "1",
      show_phases: params[:show_phases] == "1",
      show_prediction: params[:show_prediction] == "1",
      show_forecast: params[:show_forecast] == "1",
      show_superpowers: params[:show_superpowers] == "1",
      week_start_day: params[:week_start_day] || "monday",
      hide_past_events: params[:hide_past_events] == "1"
    }
    if @user.update(preferences)
      redirect_to calendar_settings_path, notice: t("settings.calendar.saved", default: "Calendar preferences saved")
    else
      redirect_to calendar_settings_path, alert: t("settings.calendar.error", default: "Failed to save preferences")
    end
  end

  def notifications
    reminders = current_user.reminders.index_by(&:reminder_type)
    current_user.notification_preferences || {}
    @notifications = NotificationSettings.new(
      reminders["morning"]&.active || false,
      reminders["period_start"]&.active || false,
      reminders["pill"]&.active || false,
      false, # appointment_reminder
      reminders["supplement"]&.active || false,
      current_user.push_subscriptions.any?,
      reminders["in_app"]&.active || false,
      "09:00"
    )
  end

  def connect_google_calendar
    # Without this, anyone can start their own OAuth flow, capture the
    # resulting code, and get a logged-in victim to visit
    # /settings/google_calendar_callback?code=<attacker's code> — the
    # callback below would exchange it and link the attacker's Google
    # Calendar to the victim's Season account. Tying the redirect to a
    # per-session value the callback must match closes that off (the classic
    # OAuth "login/connect CSRF" gap).
    state = SecureRandom.hex(16)
    session[:google_oauth_state] = state

    client = build_google_oauth_client
    auth_url = client.authorization_uri(
      scope: "https://www.googleapis.com/auth/calendar",
      access_type: "offline",
      prompt: "consent",
      state: state,
      redirect_uri: google_calendar_callback_url
    ).to_s
    redirect_to auth_url, allow_other_host: true
  end

  def google_calendar_callback
    expected_state = session.delete(:google_oauth_state)
    state_ok = expected_state.present? && params[:state].present? &&
      ActiveSupport::SecurityUtils.secure_compare(params[:state], expected_state)

    if params[:code].present? && state_ok
      client = build_google_oauth_client
      client.code = params[:code]
      client.redirect_uri = google_calendar_callback_url
      client.fetch_access_token!

      email = fetch_google_email(client.access_token)

      current_user.update!(
        google_access_token: client.access_token,
        google_refresh_token: client.refresh_token.presence || current_user.google_refresh_token,
        google_token_expires_at: client.expires_at ? Time.zone.at(client.expires_at) : nil,
        google_calendar_email: email
      )
      redirect_to calendar_settings_path, notice: t("settings.calendar.google_connected", default: "Google Calendar connected")
    else
      redirect_to calendar_settings_path, alert: t("settings.calendar.google_failed", default: "Failed to connect Google Calendar")
    end
  end

  def disconnect_google_calendar
    current_user.update!(
      google_access_token: nil,
      google_refresh_token: nil,
      google_token_expires_at: nil,
      google_calendar_email: nil,
      google_uid: nil
    )
    redirect_to calendar_settings_path, notice: t("settings.calendar.google_disconnected", default: "Google Calendar disconnected")
  end

  def sync_google_calendar
    service = GoogleCalendarService.new(current_user)
    events = service.list_events(
      time_min: 3.months.ago.iso8601,
      time_max: 3.months.from_now.iso8601,
      max_results: 250
    )

    imported = 0

    (events || []).each do |event|
      next if event.start.nil?
      next if event.start.date_time.nil? && event.start.date.nil?
      next if CalendarEvent.exists?(google_event_id: event.id)

      start_time = event.start.date_time || event.start.date.to_time
      end_time = event.end&.date_time || event.end&.date&.to_time

      CalendarEvent.create!(
        user: current_user,
        google_event_id: event.id,
        title: event.summary.presence || "Untitled",
        date: start_time.to_date,
        start_time: start_time.respond_to?(:strftime) ? start_time.strftime("%H:%M") : nil,
        end_time: end_time&.respond_to?(:strftime) ? end_time.strftime("%H:%M") : nil,
        notes: event.description,
        location: event.location
      )
      imported += 1
    end

    redirect_to calendar_settings_path, notice: t("settings.calendar.google_synced", count: imported, default: "Synced #{imported} events from Google Calendar")
  end

  KEY_TO_REMINDER = {
    "cycle_reminder" => ["morning", "09:00"],
    "period_prediction" => ["period_start", "00:00"],
    "ovulation_alert" => ["pill", "21:00"],
    "newsletter" => ["supplement", "18:00"],
    "email_notifications" => ["in_app", nil]
  }.freeze

  PREFERENCE_KEYS = %w[
    in_app_new_appt_synced in_app_tracking_reminder in_app_new_feedback
    in_app_app_updates in_app_appointments
    push_new_appt_synced push_tracking_reminder push_new_feedback
    push_app_updates push_appointments
  ].freeze

  def update_notifications
    KEY_TO_REMINDER.each do |key, (type, default_time)|
      next unless params.key?(key)

      active = ActiveModel::Type::Boolean.new.cast(params[key])
      reminder = current_user.reminders.find_or_initialize_by(reminder_type: type)
      reminder.active = active
      reminder.time ||= default_time if default_time
      reminder.save!
    end

    PREFERENCE_KEYS.each do |key|
      next unless params.key?(key)

      prefs = current_user.notification_preferences || {}
      prefs[key] = ActiveModel::Type::Boolean.new.cast(params[key])
      current_user.update!(notification_preferences: prefs)
    end

    render json: {success: true}
  end

  def update_avatar
    @user = current_user
    if params[:avatar_preset].present?
      # User selected a preset avatar
      preset = AvatarService.all.find { |p| p[:id] == params[:avatar_preset] }
      if preset
        @user.update(avatar_preset: params[:avatar_preset])
        @user.avatar.purge if @user.avatar.attached?
        @user.update(avatar_url: nil)
      end
    elsif params[:avatar].is_a?(ActionDispatch::Http::UploadedFile)
      # Also how a cropped photo arrives — avatar_crop_controller.js swaps a
      # canvas-exported File into this same file input before submitting, so
      # there's nothing crop-specific to do here; it's just a JPEG upload.
      #
      # `attach` on an already-persisted record (true here — current_user is
      # always persisted) saves the attachment immediately and unconditionally,
      # bypassing model validations entirely. valid?/save afterward correctly
      # *reports* an oversized/wrong-type file as invalid, but the bad blob is
      # already sitting in storage and attached by then regardless — it has to
      # be purged by hand on failure, or the User#avatar validation added
      # alongside this is just a report, not an actual gate.
      @user.avatar.attach(params[:avatar])
      if @user.valid?
        @user.update(avatar_preset: nil)
      else
        @user.avatar.purge
      end
    end
    # Pasting an image URL used to be a third option here (avatar_url) — the
    # picker no longer offers it, so this action no longer accepts one, even
    # if something still POSTs the param directly. Existing users who already
    # have avatar_url set keep displaying it fine (see User#avatar_url reads
    # across the views); only *setting a new one* this way is gone.
    # The avatar modal is opened from /settings/profile and from /tracking;
    # land the user back where they made the change, not always profile.
    safe_return = params[:return_to].in?([tracking_index_path, profile_settings_path]) ? params[:return_to] : nil
    redirect_to safe_return || profile_settings_path
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

  def update_password
    @user = current_user
    unless @user.valid_password?(params[:current_password].to_s)
      # Rendered inline inside the reopened password modal (see profile.html.erb),
      # not the top-of-page flash banner — that was easy to miss since this form
      # does a full page reload, closing the modal, with no error visible on it.
      redirect_to profile_settings_path, flash: {password_modal_error: t(".invalid_password", default: "Current password is wrong, please try again")}
      return
    end

    if @user.update(password: params[:password], password_confirmation: params[:password_confirmation])
      # Re-issues the session + persistent cookie with a fingerprint of the
      # *new* password hash — without this, this device's own remember-me
      # cookie would go stale from the fingerprint check in
      # Authentication#user_from_remember_cookie the next time its session
      # expires, forcing an unnecessary re-login on the device that just
      # proved its identity by supplying the current password above.
      login(@user)
      redirect_to profile_settings_path, notice: t(".saved", default: "Password updated.")
    else
      message = if @user.errors[:password_confirmation].present?
        t(".passwords_not_identical", default: "New passwords are not identical, please try again")
      else
        @user.errors.full_messages.to_sentence
      end
      redirect_to profile_settings_path, flash: {password_modal_error: message}
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

  allow_pin_bypass only: [:pin, :update_pin, :remove_pin]

  def pin
    @user = current_user
  end

  def update_pin
    @user = current_user
    code = params[:pin].to_s
    if code.length < 4 || code.length > 6 || !code.match?(/\A\d+\z/)
      redirect_to pin_settings_path, alert: t("settings.pin.invalid", default: "Code must be 4-6 digits")
    elsif params[:pin_confirmation] != code
      redirect_to pin_settings_path, alert: t("settings.pin.mismatch", default: "Codes do not match")
    else
      @user.set_pin(code)
      mark_pin_verified!
      redirect_to profile_settings_path, notice: t("settings.pin.saved", default: "Access code saved")
    end
  end

  def remove_pin
    @user = current_user
    if @user.pin_set? && @user.verify_pin(params[:pin])
      @user.remove_pin
      session.delete(:pin_verified_at)
      redirect_to profile_settings_path, notice: t("settings.pin.removed", default: "Access code removed")
    else
      redirect_to profile_settings_path, alert: t("settings.pin.incorrect", default: "Incorrect code")
    end
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

    redirect_to "/settings/consent", notice: t("consent.saved")
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

  def build_google_oauth_client
    Signet::OAuth2::Client.new(
      client_id: ENV["GOOGLE_CLIENT_ID"],
      client_secret: ENV["GOOGLE_CLIENT_SECRET"],
      authorization_uri: "https://accounts.google.com/o/oauth2/auth",
      token_credential_uri: "https://oauth2.googleapis.com/token"
    )
  end

  def google_calendar_callback_url
    "#{request.base_url}/settings/google_calendar_callback"
  end

  def fetch_google_email(access_token)
    uri = URI("https://www.googleapis.com/oauth2/v3/userinfo")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(uri)
    request["Authorization"] = "Bearer #{access_token}"
    response = http.request(request)
    JSON.parse(response.body)["email"]
  rescue
    nil
  end
end
