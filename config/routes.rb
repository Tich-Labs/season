Rails.application.routes.draw do
  get "/app", to: "home#app", as: :app_landing
  get "/loader", to: "home#loader", as: :loader
  get "/welcome", to: "home#welcome", as: :welcome

  resource :registration, only: [:new, :create]
  resource :session, only: [:new, :create, :destroy]

  # Devise for password recovery
  devise_for :users, only: [:password], controllers: {passwords: "passwords"}

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
  resources :onboarding, only: [:show, :update] do
    collection do
      get :finish
    end
  end

  get "calendar", to: "calendar#index", as: :user_root
  resources :calendar_events, except: [:index, :show]
  resources :tracking, only: [:index, :create]
  get "daily/:date", to: "daily_view#show", as: :daily_view
  resources :streaks, only: [:index]
  resources :symptoms, only: [:index, :show, :create, :update]
  resources :superpowers, only: [:index, :show, :create, :update]
  resource :settings, only: [:edit, :update] do
    get :profile, on: :collection
    get :subscriptions, on: :collection
    get :calendar, on: :collection
  end

  namespace :admin do
    resources :users, only: [:index, :show]
    root to: "users#index"
  end

  get "up" => "rails/health#show", :as => :rails_health_check

  get "/launch", to: "launch#index", as: :launch

  # Legal pages (to be built)
  get "/terms", to: "legal#terms", as: :terms
  get "/privacy", to: "legal#privacy", as: :privacy

  root "home#loader"
end
