# Outline of where user data is stored — server-side (PostgreSQL) vs on the
# user's device (cookies, localStorage, service worker cache, iOS WebView).
# Intended as the source for GDPR/DPIA reporting (see docs/userdata.md).
#
# Column lists are derived from the live schema rather than hardcoded output,
# so the page stays accurate as migrations land: Devise columns come from an
# explicit allowlist, everything else on `users` is shown as app-owned.
class Admin::DataStorageController < Admin::BaseController
  DEVISE_COLUMNS = %w[
    email encrypted_password reset_password_token reset_password_sent_at
    remember_created_at confirmation_token confirmed_at confirmation_sent_at
    unconfirmed_email
  ].freeze

  APP_COLUMN_GROUPS = {
    "Identity & account" => %w[
      name birthday public_id language admin plan
    ],
    "Onboarding & cycle" => %w[
      onboarding_completed has_regular_cycle cycle_length period_length
      last_period_start last_period_end uses_hormonal_birth_control
      contraception_type birth_control_reminder cycle_stage_reminder
      food_preference life_stage
    ],
    "Calendar preferences" => %w[
      week_start_day hide_past_events show_appointments show_cycledays
      show_moonphases show_week_numbers show_forecast show_prediction
      show_phases show_superpowers show_tracked_days show_cycle_day_on_band
    ],
    "Google Calendar integration" => %w[
      google_uid google_access_token google_refresh_token
      google_token_expires_at google_calendar_email
    ],
    "Other sign-in identifiers" => %w[facebook_uid apple_uid],
    "App security (not Devise)" => %w[pin_digest],
    "Email deliverability" => %w[email_bounce_type email_bounced_at],
    "Invite system" => %w[invite_token invite_token_expires_at invite_accepted_at],
    "Avatar & preferences" => %w[avatar_preset avatar_url notification_preferences]
  }.freeze

  # Related tables keyed by user_id, with their owning associations. Counts are
  # live so the report always reflects current volume.
  DATA_TABLES = [
    ["User", User, "Accounts — the row every other record points at"],
    ["Cycle entries", CycleEntry, "Menstrual periods logged"],
    ["Period starts", PeriodStart, "Period start markers (ordered list)"],
    ["Symptom logs", SymptomLog, "Mood / physical / mental / other tracked symptoms"],
    ["Superpower logs", SuperpowerLog, "Superpower tracking entries"],
    ["Calendar events", CalendarEvent, "Appointments & events (incl. Google-synced)"],
    ["Reminders", Reminder, "Birth control / cycle-stage reminders"],
    ["Notifications", Notification, "In-app notifications"],
    ["Streaks", Streak, "Current tracking streak"],
    ["Feedback & support", Feedback, "Feedback / bug / support messages"],
    ["Weekly feedback responses", WeeklyFeedbackResponse, "8-week survey answers"],
    ["Consents", UserConsent, "GDPR consent records (health data, analytics, etc.)"],
    ["Push subscriptions", PushSubscription, "Web push endpoints (device token points here)"],
    ["WebAuthn credentials", WebauthnCredential, "Passkey public keys (private key stays on device)"],
    ["Avatar attachments", ActiveStorage::Attachment, "Uploaded avatar images (blobs stored separately)"]
  ].freeze

  def index
    schema_columns = User.columns
    @devise_columns = schema_columns.select { |c| DEVISE_COLUMNS.include?(c.name) }
    @app_column_groups = APP_COLUMN_GROUPS.filter_map do |label, names|
      present = schema_columns.select { |c| names.include?(c.name) }
      [label, present] unless present.empty?
    end

    listed = (DEVISE_COLUMNS + APP_COLUMN_GROUPS.values.flatten).map(&:to_s)
    boilerplate = %w[id created_at updated_at]
    @uncategorised = schema_columns.reject { |c| listed.include?(c.name) || boilerplate.include?(c.name) }

    @data_tables = DATA_TABLES.map do |label, model, note|
      [label, safe_count(model), note]
    end
  end

  private

  def safe_count(model)
    model.count
  rescue ActiveRecord::StatementInvalid, NameError
    "n/a"
  end
end
