# Be sure to restart your server when you modify this file.

# Configure parameters to be partially matched (e.g. passw matches password) and filtered from the log file.
# Use this to limit dissemination of sensitive information.
# See the ActiveSupport::ParameterFilter documentation for supported notations and behaviors.
Rails.application.config.filter_parameters += [
  :passw, :email, :secret, :token, :_key, :crypt, :salt, :certificate, :otp, :ssn, :cvv, :cvc,
  :pin, :api_key, :auth, :authorization, :credit_card,
  # Identity and OAuth UIDs
  :name, :google_uid, :facebook_uid, :apple_uid,
  # Health data (GDPR Art. 9). Partial matching also covers mood_text,
  # physical_symptoms, intercourse_tags, etc.
  :birthday, :last_period_start, :last_period_end, :period_start, :period_end, :started_on,
  :cycle_length, :period_length, :has_regular_cycle, :contraception_type,
  :uses_hormonal_birth_control, :food_preference, :life_stage,
  :mood, :energy, :sleep, :physical, :mental, :pain, :cravings, :discharge, :bleeding,
  :temperature, :weight, :sexual_intercourse, :intercourse_tags, :ratings,
  # Free text that can describe health or appointments
  :notes, :message, :title, :location, :guests
]
