class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :validatable,
    :confirmable,
    :omniauthable, omniauth_providers: [:google_oauth2, :facebook, :apple]

  validates :name, presence: true, if: :onboarding_completed?

  has_one_attached :avatar
  has_many :cycle_entries, dependent: :destroy
  has_many :calendar_events, dependent: :destroy
  has_many :symptom_logs, dependent: :destroy
  has_many :superpower_logs, dependent: :destroy
  has_many :reminders, dependent: :destroy
  has_many :feedbacks, dependent: :destroy
  has_many :weekly_feedback_responses, dependent: :destroy
  has_many :user_consents, dependent: :destroy
  has_many :push_subscriptions, dependent: :destroy
  has_many :period_starts, dependent: :destroy

  store_accessor :notification_preferences,
    :in_app_new_appt_synced, :in_app_tracking_reminder, :in_app_new_feedback,
    :in_app_app_updates, :in_app_appointments,
    :push_new_appt_synced, :push_tracking_reminder, :push_new_feedback,
    :push_app_updates, :push_appointments
  has_many :webauthn_credentials, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_one :streak, dependent: :destroy

  def current_feedback_week
    return nil if created_at.nil?
    week = ((Time.current - created_at) / 7.days).ceil.clamp(1, 8)
    (week > 8) ? nil : week
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[email name created_at onboarding_completed language public_id]
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end

  # Required fields per onboarding step. Steps with a "skip" option
  # (3, 5, 7, 8, 9) are intentionally omitted — users may legitimately leave those nil.
  REQUIRED_ONBOARDING_STEPS = {
    1 => ->(u) { u.name.present? },
    2 => ->(u) { u.birthday.present? },
    4 => ->(u) { !u.has_regular_cycle.nil? },
    6 => ->(u) { !u.uses_hormonal_birth_control.nil? },
    10 => ->(u) { u.food_preference.present? }
  }.freeze

  # All 10 onboarding steps in sequence. Used for resume redirect on sign-in.
  # Step 3 covers both period start and end (a single date-range picker).
  ALL_ONBOARDING_STEPS = {
    1 => ->(u) { u.name.present? },
    2 => ->(u) { u.birthday.present? },
    3 => ->(u) { u.last_period_start.present? },
    4 => ->(u) { !u.has_regular_cycle.nil? },
    5 => ->(u) { u.cycle_length.present? },
    6 => ->(u) { !u.uses_hormonal_birth_control.nil? },
    7 => ->(u) { u.uses_hormonal_birth_control == true || !u.birth_control_reminder.nil? },
    8 => ->(u) { u.contraception_type.present? && u.contraception_type != "none" },
    9 => ->(u) { !u.cycle_stage_reminder.nil? },
    10 => ->(u) { u.food_preference.present? }
  }.freeze

  # Returns the first step number where data is still missing (in sequential
  # order), or nil if onboarding is already completed. Used to resume
  # onboarding after sign-in for users who haven't finished yet.
  def next_onboarding_step
    return nil if onboarding_completed?
    ALL_ONBOARDING_STEPS.find { |_step, check| !check.call(self) }&.first
  end

  # Returns the first step where REQUIRED data is missing, or nil when
  # all required fields are present. Used to check if user can access app.
  def first_incomplete_onboarding_step
    REQUIRED_ONBOARDING_STEPS.find { |_step, check| !check.call(self) }&.first
  end

  def profile_complete?
    first_incomplete_onboarding_step.nil?
  end

  def onboarding_completed?
    onboarding_completed == true
  end

  def current_phase
    return nil unless last_period_start || period_starts.any?
    CycleCalculatorService.new(self).current_phase
  end

  def current_cycle_day(date = Time.zone.today)
    return nil unless last_period_start || period_starts.any?
    (date.to_date - (period_starts.ordered.last&.started_on || last_period_start).to_date).to_i + 1
  end

  def first_name
    name&.split&.first || name
  end

  def consent?(consent_type)
    user_consents.active.exists?(consent_type: consent_type)
  end

  def health_consent?
    consent?("health_data_processing")
  end

  def self.find_or_create_from_oauth(provider, auth)
    uid_column = resolve_oauth_uid_column(provider)
    email = auth.info.email&.downcase

    # UID-first lookup handles Apple repeat logins where email is absent after first auth
    user = find_by(uid_column => auth.uid) if auth.uid.present?
    user ||= find_or_initialize_by(email: email) if email.present?
    return User.new unless user

    user.assign_attributes(
      :name => auth.info.name.presence || user.name,
      uid_column => auth.uid
    )
    user.language = I18n.locale.to_s if user.new_record?

    if user.new_record?
      user.skip_confirmation!
      user.password = Devise.friendly_token[0, 20]
      user.password_confirmation = user.password
      user.save!
    elsif user.public_send(uid_column).blank?
      user.update(uid_column => auth.uid)
    end

    user
  rescue ActiveRecord::RecordInvalid, ArgumentError
    user || User.new
  end

  def self.resolve_oauth_uid_column(provider)
    case provider
    when "google_oauth2" then "google_uid"
    when "facebook" then "facebook_uid"
    when "apple" then "apple_uid"
    else raise ArgumentError, "Unknown OAuth provider: #{provider}"
    end
  end

  def store_google_tokens!(auth)
    creds = auth.credentials
    update!(
      google_access_token: creds.token,
      google_refresh_token: creds.refresh_token.presence || google_refresh_token,
      google_token_expires_at: creds.expires_at ? Time.zone.at(creds.expires_at) : nil
    )
  end

  def google_calendar_connected?
    google_access_token.present? && google_refresh_token.present?
  end

  def set_pin(raw)
    self.pin_digest = BCrypt::Password.create(raw)
    save!
  end

  def authenticate_pin(raw)
    return false if pin_digest.blank?
    BCrypt::Password.new(pin_digest) == raw
  end
  alias_method :verify_pin, :authenticate_pin

  def pin_set?
    pin_digest.present?
  end

  def remove_pin
    update!(pin_digest: nil)
  end

  def refresh_google_token_if_needed!
    return false unless google_calendar_connected?
    return false if google_token_expires_at.nil? || google_token_expires_at > 5.minutes.from_now

    client = Signet::OAuth2::Client.new(
      client_id: ENV["GOOGLE_CLIENT_ID"],
      client_secret: ENV["GOOGLE_CLIENT_SECRET"],
      token_credential_uri: "https://oauth2.googleapis.com/token",
      refresh_token: google_refresh_token
    )
    client.fetch_access_token!
    update!(
      google_access_token: client.access_token,
      google_token_expires_at: Time.zone.at(client.expires_at)
    )
    true
  rescue Signet::AuthorizationError => e
    Rails.logger.error "[Google Calendar] Token refresh failed: #{e.message}"
    false
  end
end
