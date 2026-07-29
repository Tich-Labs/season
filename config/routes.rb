Rails.application.routes.draw do
  resources :notifications, only: [:index, :show, :destroy] do
    member do
      patch :mark_read
    end
  end
  get "health", to: proc { |env|
    status = {
      rails: "ok",
      database: "unknown",
      resend: ENV["RESEND_API_KEY"].present? ? "configured" : "missing"
    }
    begin
      ActiveRecord::Base.connection.execute("SELECT 1")
      status[:database] = "ok"
    rescue
      status[:database] = "error"
    end
    code = (status[:database] == "ok" && status[:resend] == "configured") ? 200 : 503
    [code, {"Content-Type" => "application/json"}, [status.to_json]]
  }
  unless Rails.env.production?
    get "test-email-prod", to: proc { |env|
      begin
        if ENV["RESEND_API_KEY"].blank?
          [500, {"Content-Type" => "application/json"}, [{error: "RESEND_API_KEY not set"}]]
        else
          result = Resend::Emails.send({
            from: ENV.fetch("RESEND_FROM_EMAIL", "onboarding@resend.dev"),
            to: ENV.fetch("RESEND_TEST_TO", "delivered@resend.dev"),
            subject: "Production Test from Season",
            html: "<p>Production email test working!</p>"
          })
          [200, {"Content-Type" => "application/json"}, [result.inspect]]
        end
      rescue => e
        [500, {"Content-Type" => "application/json"}, [{error: e.class, message: e.message}]]
      end
    }
  end
  unless Rails.env.production?
    get "test-db", to: proc { |env| [200, {"Content-Type" => "text/plain"}, ["OK - Rails #{Rails.env}"]] }
    get "test-load", to: proc { |env|
      begin
        require "registrations_controller"
        klass = RegistrationsController
        [200, {"Content-Type" => "text/plain"}, ["Controller loads OK: #{klass}"]]
      rescue => e
        [500, {"Content-Type" => "text/plain"}, ["Error: #{e.class}: #{e.message}\n#{e.backtrace.first(3).join("\n")}"]]
      end
    }
    get "test-email", to: proc { |env|
      begin
        result = Resend::Emails.send({
          from: ENV.fetch("RESEND_FROM_EMAIL", "onboarding@resend.dev"),
          to: ENV.fetch("RESEND_TEST_TO", "delivered@resend.dev"),
          subject: "Test from Season",
          html: "<p>Working!</p>"
        })
        [200, {"Content-Type" => "application/json"}, [result.inspect]]
      rescue => e
        [500, {"Content-Type" => "application/json"}, [{error: e.message}]]
      end
    }
  end

  get "/app", to: "home#app", as: :app_landing
  get "/loader", to: "home#loader", as: :loader
  get "/welcome", to: "home#welcome", as: :welcome
  post "/launch-signup", to: "launch_signups#create"

  resource :registration, only: [:new, :create] do
    get :check_email, on: :collection
  end
  resource :session, only: [:new, :create, :destroy] do
    get :user_status, on: :collection
    post :pin_login, on: :collection
  end

  # Redirect Devise's default /users/sign_in to our custom Season login page.
  # Warden's failure app and any external links pointing here will land on Season UI.
  get "/users/sign_in", to: redirect("/session/new")

  # Devise for password recovery + OmniAuth only — sessions handled by our own SessionsController
  devise_for :users,
    controllers: {
      passwords: "passwords",
      confirmations: "confirmations",
      omniauth_callbacks: "users/omniauth_callbacks"
    },
    skip: [:sessions],
    omniauth_providers: [:google_oauth2, :facebook, :apple]

  # Custom password routes at /password/*
  get "password/new", to: redirect("/users/password/new")
  get "password/edit", to: redirect("/users/password/edit")
  get "password/done", to: "passwords#done", as: :done_password
  get "password/error/already-reset", to: "passwords#error_already_reset", as: :password_error_already_reset
  get "password/error/link-expired", to: "passwords#error_link_expired", as: :password_error_link_expired
  get "password/error/inbox-full", to: "passwords#error_inbox_full", as: :password_error_inbox_full
  get "password/error/wrong-email", to: "passwords#error_wrong_email", as: :password_error_wrong_email
  get "password/error/contact", to: "passwords#error_contact", as: :password_error_contact

  get "manifest.json", to: "pwa#manifest", format: :json, as: :pwa_manifest
  get "service-worker.js", to: "pwa#service_worker", format: :js

  get "invite/:token", to: "invites#show", as: :invite
  patch "invite/:token", to: "invites#update"
  get "onboarding/finish", to: "onboarding#finish", as: :onboarding_finish
  resources :onboarding, only: [:show, :update]

  get "calendar", to: "calendar#index", as: :user_root
  get "calendar", to: "calendar#index", as: :calendar
  get "calendar/weekly", to: "calendar#weekly", as: :calendar_weekly
  get "calendar/appointments", to: "calendar#appointments", as: :calendar_appointments
  resources :calendar_events
  resources :tracking, only: [:index, :create] do
    collection do
      get :period
      patch :period, action: :period_update
    end
  end
  get "tracking/period", to: "tracking#period", as: :period_tracking_path
  get "daily/:date", to: "daily_view#show", as: :daily_view
  resources :streaks, only: [:index]
  get "symptoms/discharge", to: "symptoms#discharge", as: :symptom_discharge
  post "symptoms/log_physical", to: "symptoms#log_physical", as: :log_physical_symptom
  post "symptoms/log_mental", to: "symptoms#log_mental", as: :log_mental_symptom
  post "symptoms/log_bleeding", to: "symptoms#log_bleeding", as: :log_bleeding_symptom
  resources :symptoms, only: [:index, :show, :create, :update]
  resources :superpowers, only: [:index, :show, :create, :update]
  resources :feedbacks, only: [:create]
  get "weekly_feedback", to: "weekly_feedbacks#show", as: :weekly_feedback
  post "weekly_feedback/submit", to: "weekly_feedbacks#submit", as: :submit_weekly_feedback
  resource :settings, only: [:edit, :update] do
    get :profile, on: :collection
    get :subscriptions, on: :collection
    get :calendar, on: :collection
    get :notifications, on: :collection
    get :notification_morning, on: :collection
    get :notification_period, on: :collection
    get :notification_birth_control, on: :collection
    patch :update_avatar, on: :collection
    patch :update_profile, on: :collection
    patch :update_calendar, on: :collection
    patch :update_notifications, on: :collection
    patch :save_morning_reminder, on: :collection
    patch :save_period_reminder, on: :collection
    patch :save_birth_control_reminder, on: :collection
    get :pin, on: :collection
    post :pin, on: :collection, action: :update_pin
    delete :pin, on: :collection, action: :remove_pin
    get :connect_google_calendar, on: :collection
    get :google_calendar_callback, on: :collection
    post :disconnect_google_calendar, on: :collection
    post :sync_google_calendar, on: :collection
  end

  # Language selection - explicit routes after settings resource
  get "settings/language", to: "settings/language#show", as: :settings_language
  patch "settings/language", to: "settings/language#update"

  get "unlock", to: "pin#show", as: :pin_unlock
  post "unlock", to: "pin#verify"

  get "push/vapid-key", to: "push#vapid_public_key", as: :vapid_key
  post "push/subscribe", to: "push#subscribe"
  delete "push/unsubscribe", to: "push#unsubscribe"

  get "webauthn/registration-challenge", to: "webauthn#registration_challenge"
  post "webauthn/register", to: "webauthn#register"
  get "webauthn/authentication-challenge", to: "webauthn#authentication_challenge"
  post "webauthn/authenticate", to: "webauthn#authenticate"
  delete "webauthn/credentials/:id", to: "webauthn#destroy"

  get "settings/consent", to: "settings#consent", as: nil
  post "settings/consent", to: "settings#save_consents", as: nil

  resource :account, only: [:show] do
    get :export, on: :collection
    delete :destroy, on: :collection
  end

  # Explicit consent for GDPR Article 9 - uses settings/consent
  # (duplicate named route removed to avoid conflicts)

  namespace :admin do
    get "login", to: "sessions#new", as: :login
    post "login", to: "sessions#create"
    delete "logout", to: "sessions#destroy", as: :logout
    resources :users, only: [:index, :show, :update, :destroy]
    get "inbox", to: "inbox#overview", as: :inbox
    get "inbox/feedback", to: "inbox#feedback"
    get "inbox/bugs", to: "inbox#bugs"
    get "inbox/support", to: "inbox#support"
    get "inbox/export_csv", to: "inbox#export_csv"
    get "launch_signups", to: "launch_signups#index", as: :launch_signups
    get "launch_signups/export_csv", to: "launch_signups#export_csv", as: :launch_signups_export_csv
    resources :cycle_phase_contents, except: [:show]
    resources :cycle_day_contents, except: [:show] do
      collection do
        post :import_csv
      end
    end
    resources :weekly_feedback_questions, except: [:show]
    get "weekly_feedback_responses", to: "weekly_feedback_responses#index", as: :weekly_feedback_responses
    get "weekly_feedback_responses/export_csv", to: "weekly_feedback_responses#export_csv", as: :weekly_feedback_responses_export_csv
    get "help", to: "pages#help", as: :help
    get "board", to: "board#index", as: :board
    root to: "users#index"
  end

  post "test_results/submit", to: "test_results#submit"

  get "forecast", to: "forecast#index", as: :forecast

  get "up" => "rails/health#show", :as => :rails_health_check
  get "ping" => ->(env) { [200, {"Content-Type" => "text/plain"}, ["OK"]] }

  unless Rails.env.production?
    get "test" => "debug#test"
    get "model-test", to: ->(env) {
      begin
        user_count = User.count
        [200, {"Content-Type" => "text/plain"}, ["User count: #{user_count}"]]
      rescue => e
        [500, {"Content-Type" => "text/plain"}, ["Error: #{e.message}"]]
      end
    }
    get "i18n-test", to: ->(env) {
      I18n.locale = I18n.default_locale
      test = I18n.t("devise.registrations.new.subtitle", default: "NOT FOUND")
      [200, {"Content-Type" => "text/plain"}, ["I18n test: #{test}"]]
    }
    get "env", to: ->(env) {
      body = "Rails: #{Rails.env}\nEager: #{Rails.application.config.eager_load?}\n"
      body += "SECRET_KEY_BASE: #{ENV["SECRET_KEY_BASE"]&.present? ? "set" : "missing"}\n"
      body += "DATABASE_URL: #{ENV["DATABASE_URL"]&.present? ? "set" : "missing"}\n"
      body += "RAILS_MASTER_KEY: #{ENV["RAILS_MASTER_KEY"]&.present? ? "set" : "missing"}\n"
      [200, {"Content-Type" => "text/plain"}, [body]]
    }
  end

  get "information", to: "information#index", as: :information
  get "information/:phase", to: "information#show", as: :information_phase

  get "/launch", to: "launch#index", as: :launch
  get "/countdown", to: "home#countdown", as: :countdown_page

  # Legal pages (to be built)
  get "/terms", to: "legal#terms", as: :terms
  get "/privacy", to: "legal#privacy", as: :privacy

  # Ruby Native iOS configuration endpoint
  get "/configurations/ios_v1", to: "configurations#ios_v1", defaults: {format: :json}
  get "/configurations/android_v1", to: "configurations#android_v1", defaults: {format: :json}

  # Native device registration for APNs
  post "/native_devices/register", to: "native_devices#register", defaults: {format: :json}

  root "home#welcome"
end
