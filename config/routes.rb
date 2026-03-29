Rails.application.routes.draw do
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", :as => :rails_health_check

  get "manifest" => "rails/pwa#manifest", :as => :pwa_manifest
  get "service-worker" => "rails/pwa#service_worker", :as => :pwa_service_worker

  root "home#index"

  get "onboarding" => "onboarding#show"
  post "onboarding" => "onboarding#update"
  get "settings" => "home#settings"
  get "preview/calendar" => "home#preview_calendar"
  get "preview/settings" => "home#preview_settings"
end
