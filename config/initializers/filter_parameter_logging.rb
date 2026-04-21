# Be sure to restart your server when you modify this file.

# Configure parameters to be partially matched (e.g. passw matches password) and filtered from the log file.
# Use this to limit dissemination of sensitive information.
# See the ActiveSupport::ParameterFilter documentation for supported notations and behaviors.
Rails.application.config.filter_parameters += [
  # Standard Rails / auth (partial-match — e.g. :passw matches "encrypted_password")
  :passw, :secret, :token, :_key, :crypt, :salt, :certificate, :otp, :ssn, :cvv, :cvc,

  # Identity — never log email or name in request params
  :email, :name,

  # OAuth UIDs — each provider listed explicitly to avoid over-broad matching
  :google_uid, :facebook_uid, :apple_uid,

  # Health data — GDPR Article 9 special category
  # These must never appear in logs, even in development
  :birthday, :last_period_start,
  :cycle_length, :period_length,
  :has_regular_cycle, :contraception_type, :uses_hormonal_birth_control,
  :food_preference, :life_stage,

  # Symptom log fields — all user health signals
  :mood, :energy, :sleep, :physical, :mental,
  :pain, :cravings, :discharge,
  :temperature, :weight, :sexual_intercourse,
  :notes
]
