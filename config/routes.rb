Rails.application.routes.draw do
  get "/loader", to: "home#loader", as: :loader
  get "/welcome", to: "home#welcome", as: :welcome
  devise_for :users

  # PWA routes
  get "manifest.json", to: "pwa#manifest", format: :json, as: :pwa_manifest
  get "service-worker.js", to: "pwa#service_worker", format: :js

  get "invite/:token", to: "onboarding#invite", as: :invite_link
  resources :onboarding, only: [ :show, :update ] do
    collection do
      get :finish
    end
  end

  get "calendar", to: "calendar#index", as: :user_root
  get "tracking", to: "tracking#index", as: :tracking
  get "daily/:date", to: "daily_view#show", as: :daily_view
  resources :streaks, only: [ :index ]
  resources :symptoms, only: [ :index, :show ]
  resources :superpowers, only: [ :index, :show ]
  resource :settings, only: [ :edit, :update ]

  namespace :admin do
    resources :users, only: [ :index, :show ]
    root to: "users#index"
  end

  get "up" => "rails/health#show", :as => :rails_health_check

  get "/launch", to: "launch#index", as: :launch
  root "home#loader"
end
