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

ActiveRecord::Schema[8.0].define(version: 2026_04_07_045533) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "calendar_events", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "title"
    t.date "date"
    t.time "start_time"
    t.time "end_time"
    t.string "category"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_calendar_events_on_user_id"
  end

  create_table "cycle_entries", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "cycle_day"
    t.date "date"
    t.boolean "period_end"
    t.boolean "period_start"
    t.string "phase"
    t.string "season_name"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["date"], name: "index_cycle_entries_on_date"
    t.index ["user_id", "date"], name: "index_cycle_entries_on_user_id_and_date"
    t.index ["user_id"], name: "index_cycle_entries_on_user_id"
  end

  create_table "cycle_phase_contents", force: :cascade do |t|
    t.string "phase"
    t.string "locale"
    t.string "season_name"
    t.text "superpower_text"
    t.text "mood_text"
    t.text "take_care_text"
    t.text "sport_text"
    t.text "nutrition_text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "reminders", force: :cascade do |t|
    t.boolean "active"
    t.integer "break_days"
    t.datetime "created_at", null: false
    t.text "message"
    t.string "name"
    t.integer "pill_days"
    t.string "reminder_type"
    t.time "time"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
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
    t.index ["user_id"], name: "index_streaks_on_user_id"
  end

  create_table "superpower_logs", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "date"
    t.jsonb "ratings"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["date"], name: "index_superpower_logs_on_date"
    t.index ["user_id"], name: "index_superpower_logs_on_user_id"
  end

  create_table "symptom_logs", force: :cascade do |t|
    t.integer "cravings"
    t.datetime "created_at", null: false
    t.date "date"
    t.integer "discharge"
    t.integer "energy"
    t.integer "mental"
    t.integer "mood"
    t.text "notes"
    t.integer "pain"
    t.integer "physical"
    t.boolean "sexual_intercourse", default: false
    t.integer "sleep"
    t.decimal "temperature"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.decimal "weight"
    t.index ["date"], name: "index_symptom_logs_on_date"
    t.index ["user_id", "date"], name: "index_symptom_logs_on_user_id_and_date", unique: true
    t.index ["user_id"], name: "index_symptom_logs_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.date "birthday"
    t.string "contraception_type", default: "none"
    t.datetime "created_at", null: false
    t.integer "cycle_length"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "invite_accepted_at"
    t.string "invite_token"
    t.string "language", default: "en"
    t.date "last_period_start"
    t.string "life_stage", default: "menstrual"
    t.string "name"
    t.boolean "onboarding_completed"
    t.integer "period_length"
    t.string "plan", default: "free"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.datetime "updated_at", null: false
    t.string "google_uid"
    t.string "facebook_uid"
    t.string "apple_uid"
    t.string "locale"
    t.boolean "admin", default: false, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["invite_token"], name: "index_users_on_invite_token"
    t.index ["language"], name: "index_users_on_language"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "calendar_events", "users"
  add_foreign_key "cycle_entries", "users"
  add_foreign_key "reminders", "users"
  add_foreign_key "streaks", "users"
  add_foreign_key "superpower_logs", "users"
  add_foreign_key "symptom_logs", "users"
end
