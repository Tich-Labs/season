class HomeController < ApplicationController
  allow_unauthenticated_access
  layout "launch", only: [:loader, :app, :countdown]

  def app
    redirect_to onboarding_path(1) if authenticated? && !current_user&.onboarding_completed?
  end

  def loader
  end

  def welcome
    redirect_to user_root_path if authenticated? && current_user&.onboarding_completed?
    redirect_to onboarding_path(1) if authenticated? && !current_user&.onboarding_completed?
  end

  def countdown
  end
end
