# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_06_03_131520) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "calendar_events", force: :cascade do |t|
    t.string "category"
    t.datetime "created_at", null: false
    t.date "date", null: false
    t.time "end_time"
    t.text "notes"
    t.time "start_time"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id", "date"], name: "index_calendar_events_on_user_id_and_date"
    t.index ["user_id"], name: "index_calendar_events_on_user_id"
  end

  create_table "cycle_day_contents", force: :cascade do |t|
    t.string "card_type", null: false
    t.datetime "created_at", null: false
    t.integer "cycle_day", null: false
    t.jsonb "food_items"
    t.string "locale", default: "en", null: false
    t.text "long_text"
    t.text "short_text"
    t.datetime "updated_at", null: false
    t.index ["cycle_day", "card_type", "locale"], name: "index_cycle_day_contents_on_cycle_day_and_card_type_and_locale", unique: true
  end

  create_table "cycle_entries", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "cycle_day"
    t.date "date", null: false
    t.boolean "period_end", default: false, null: false
    t.boolean "period_start", default: false, null: false
    t.string "phase", null: false
    t.string "season_name"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["date"], name: "index_cycle_entries_on_date"
    t.index ["user_id", "date"], name: "index_cycle_entries_on_user_id_and_date"
    t.index ["user_id", "date"], name: "index_cycle_entries_on_user_id_and_date_unique", unique: true
  end

  create_table "cycle_phase_contents", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "dietary_preference", default: "", null: false
    t.string "locale", null: false
    t.text "mood_text"
    t.text "nutrition_text"
    t.string "phase", null: false
    t.string "season_name"
    t.text "sport_text"
    t.text "superpower_text"
    t.text "take_care_text"
    t.datetime "updated_at", null: false
    t.index ["phase", "locale", "dietary_preference"], name: "idx_cycle_phase_contents_on_phase_locale_dietary", unique: true
  end

  create_table "feedbacks", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.string "attachment"
    t.datetime "created_at", null: false
    t.text "message", null: false
    t.string "screenshot_url"
    t.string "type", default: "feedback", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_feedbacks_on_user_id"
  end

  create_table "launch_signups", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.datetime "updated_at", null: false
  end

  create_table "native_devices", force: :cascade do |t|
    t.string "app_version"
    t.datetime "created_at", null: false
    t.string "device_token", null: false
    t.string "platform", default: "ios", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["device_token"], name: "index_native_devices_on_device_token", unique: true
    t.index ["user_id"], name: "index_native_devices_on_user_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "notification_type", default: "info", null: false
    t.datetime "read_at"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id", "created_at"], name: "index_notifications_on_user_id_and_created_at"
    t.index ["user_id", "read_at"], name: "index_notifications_on_user_id_and_read_at"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "push_subscriptions", force: :cascade do |t|
    t.string "auth_key", null: false
    t.datetime "created_at", null: false
    t.string "device_type", default: "browser"
    t.string "endpoint", null: false
    t.string "p256dh_key", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["endpoint"], name: "index_push_subscriptions_on_endpoint", unique: true
    t.index ["user_id"], name: "index_push_subscriptions_on_user_id"
  end

  create_table "reminders", force: :cascade do |t|
    t.boolean "active", default: false, null: false
    t.integer "advance_days"
    t.integer "break_days"
    t.datetime "created_at", null: false
    t.text "message"
    t.string "name"
    t.integer "pill_days"
    t.string "reminder_type"
    t.time "time"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id", "active"], name: "index_reminders_on_user_id_and_active"
    t.index ["user_id"], name: "index_reminders_on_user_id"
  end

  create_table "streaks", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "current_streak", default: 0
    t.date "last_tracked_date"
    t.integer "longest_streak", default: 0
    t.integer "total_flames", default: 0
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_streaks_on_user_id", unique: true
  end

  create_table "superpower_logs", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "date", null: false
    t.jsonb "ratings"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id", "date"], name: "index_superpower_logs_on_user_id_and_date", unique: true
  end

  create_table "symptom_logs", force: :cascade do |t|
    t.string "bleeding"
    t.string "cravings"
    t.datetime "created_at", null: false
    t.date "date", null: false
    t.integer "discharge"
    t.integer "energy"
    t.string "intercourse_tags"
    t.integer "mental"
    t.jsonb "mental_symptoms", default: {}, null: false
    t.integer "mood"
    t.text "mood_text"
    t.jsonb "moods", default: [], null: false
    t.text "notes"
    t.integer "pain"
    t.integer "physical"
    t.jsonb "physical_symptoms", default: {}, null: false
    t.boolean "sexual_intercourse", default: false, null: false
    t.integer "sleep"
    t.decimal "temperature"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.decimal "weight"
    t.index ["date"], name: "index_symptom_logs_on_date"
    t.index ["user_id", "date"], name: "index_symptom_logs_on_user_id_and_date", unique: true
  end

  create_table "user_consents", force: :cascade do |t|
    t.string "consent_type", null: false
    t.datetime "created_at", null: false
    t.datetime "granted_at", null: false
    t.string "ip_address"
    t.text "metadata"
    t.datetime "revoked_at"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.bigint "user_id", null: false
    t.index ["consent_type"], name: "index_user_consents_on_consent_type"
    t.index ["granted_at"], name: "index_user_consents_on_granted_at"
    t.index ["user_id", "consent_type"], name: "index_user_consents_on_user_id_and_consent_type", unique: true, where: "(revoked_at IS NULL)"
    t.index ["user_id"], name: "index_user_consents_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.boolean "admin", default: false, null: false
    t.string "apple_uid"
    t.string "avatar_preset"
    t.string "avatar_url"
    t.boolean "birth_control_reminder"
    t.date "birthday"
    t.datetime "confirmation_sent_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.string "contraception_type", default: "none"
    t.datetime "created_at", null: false
    t.integer "cycle_length"
    t.boolean "cycle_stage_reminder"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "facebook_uid"
    t.string "food_preference"
    t.string "google_uid"
    t.boolean "has_regular_cycle"
    t.boolean "hide_past_events"
    t.datetime "invite_accepted_at"
    t.string "invite_token"
    t.datetime "invite_token_expires_at"
    t.string "language", default: "en", null: false
    t.date "last_period_end"
    t.date "last_period_start"
    t.string "life_stage", default: "menstrual"
    t.string "name", null: false
    t.string "native_auth_token"
    t.datetime "native_auth_token_created_at"
    t.jsonb "notification_preferences"
    t.boolean "onboarding_completed", default: false, null: false
    t.integer "period_length"
    t.string "pin_digest"
    t.string "plan", default: "free"
    t.uuid "public_id", default: -> { "gen_random_uuid()" }, null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.boolean "show_appointments", default: true
    t.boolean "show_cycledays", default: true
    t.boolean "show_forecast"
    t.boolean "show_holidays", default: false
    t.boolean "show_moonphases", default: true
    t.boolean "show_phases"
    t.boolean "show_prediction"
    t.boolean "show_superpowers"
    t.boolean "show_week_numbers", default: false
    t.string "unconfirmed_email"
    t.datetime "updated_at", null: false
    t.boolean "uses_hormonal_birth_control"
    t.string "week_start_day"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["invite_token"], name: "index_users_on_invite_token"
    t.index ["language"], name: "index_users_on_language"
    t.index ["native_auth_token"], name: "index_users_on_native_auth_token", unique: true
    t.index ["public_id"], name: "index_users_on_public_id", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "webauthn_credentials", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "credential_id", null: false
    t.string "label", default: "Default"
    t.text "public_key", null: false
    t.bigint "sign_count", default: 0, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["credential_id"], name: "index_webauthn_credentials_on_credential_id", unique: true
    t.index ["user_id"], name: "index_webauthn_credentials_on_user_id"
  end

  create_table "weekly_feedback_questions", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.jsonb "options", default: []
    t.integer "position", default: 0, null: false
    t.text "question_text", null: false
    t.string "question_type", null: false
    t.datetime "updated_at", null: false
    t.integer "week_number", null: false
    t.index ["week_number", "position"], name: "index_weekly_feedback_questions_on_week_number_and_position"
  end

  create_table "weekly_feedback_responses", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "response_text"
    t.string "selected_option"
    t.string "submission_batch_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.integer "week_number", null: false
    t.bigint "weekly_feedback_question_id", null: false
    t.index ["submission_batch_id"], name: "index_weekly_feedback_responses_on_submission_batch_id"
    t.index ["user_id", "week_number"], name: "index_weekly_feedback_responses_on_user_id_and_week_number"
    t.index ["user_id"], name: "index_weekly_feedback_responses_on_user_id"
    t.index ["weekly_feedback_question_id"], name: "index_weekly_feedback_responses_on_weekly_feedback_question_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "calendar_events", "users"
  add_foreign_key "cycle_entries", "users"
  add_foreign_key "feedbacks", "users"
  add_foreign_key "native_devices", "users"
  add_foreign_key "notifications", "users"
  add_foreign_key "push_subscriptions", "users"
  add_foreign_key "reminders", "users"
  add_foreign_key "streaks", "users"
  add_foreign_key "superpower_logs", "users"
  add_foreign_key "symptom_logs", "users"
  add_foreign_key "user_consents", "users"
  add_foreign_key "webauthn_credentials", "users"
  add_foreign_key "weekly_feedback_responses", "users"
  add_foreign_key "weekly_feedback_responses", "weekly_feedback_questions"
end
