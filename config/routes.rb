Rails.application.routes.draw do
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

  get "/app", to: "home#app", as: :app_landing
  get "/loader", to: "home#loader", as: :loader
  get "/welcome", to: "home#welcome", as: :welcome
  post "/launch-signup", to: "launch_signups#create"

  resource :registration, only: [:new, :create]
  resource :session, only: [:new, :create, :destroy]

  # Devise for password recovery + OmniAuth
  devise_for :users,
    omniauth_providers: [:google_oauth2, :facebook, :apple]

  # Custom password routes at /password/*
  get "password/new", to: redirect("/users/password/new")
  get "password/edit", to: redirect("/users/password/edit")

  get "password/done", to: "passwords#done", as: :done_password
  get "password/error/already-reset", to: "passwords#error_already_reset", as: :password_error_already_reset
  get "password/error/inbox-full", to: "passwords#error_inbox_full", as: :password_error_inbox_full
  get "password/error/wrong-email", to: "passwords#error_wrong_email", as: :password_error_wrong_email
  get "password/error/contact", to: "passwords#error_contact", as: :password_error_contact

  # OmniAuth routes
  get "/auth/failure", to: "omniauth#failure"
  match "/auth/:provider/callback", to: "omniauth#callback", via: [:get, :post]

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
  resources :calendar_events, except: [:index, :show]
  resources :tracking, only: [:index, :create]
  get "daily/:date", to: "daily_view#show", as: :daily_view
  resources :streaks, only: [:index]
  resources :symptoms, only: [:index, :show, :create, :update]
  resources :superpowers, only: [:index, :show, :create, :update]
  resources :feedbacks, only: [:create]
  resource :settings, only: [:edit, :update] do
    get :profile, on: :collection
    get :subscriptions, on: :collection
    get :calendar, on: :collection
    get :notifications, on: :collection
    patch :update_avatar, on: :collection
    patch :update_profile, on: :collection
    patch :update_notifications, on: :collection
  end

  namespace :admin do
    resources :users, only: [:index, :show]
    get "inbox", to: "inbox#overview", as: :inbox
    get "inbox/feedback", to: "inbox#feedback"
    get "inbox/bugs", to: "inbox#bugs"
    get "inbox/support", to: "inbox#support"
    get "inbox/export_csv", to: "inbox#export_csv"
    get "launch_signups", to: "launch_signups#index", as: :launch_signups
    get "launch_signups/export_csv", to: "launch_signups#export_csv", as: :launch_signups_export_csv
    root to: "users#index"
  end

  get "up" => "rails/health#show", :as => :rails_health_check
  get "ping" => ->(env) { [200, {"Content-Type" => "text/plain"}, ["OK"]] }
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
    # Test if I18n works
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

  get "/launch", to: "launch#index", as: :launch
  get "/countdown", to: "home#countdown", as: :countdown_page

  # Legal pages (to be built)
  get "/terms", to: "legal#terms", as: :terms
  get "/privacy", to: "legal#privacy", as: :privacy

  root "home#countdown"
end
