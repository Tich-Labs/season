class HomeController < ApplicationController
  allow_unauthenticated_access
  layout "launch", only: [:loader, :app]

  def app
    return if !authenticated? || current_user.nil?
    redirect_to onboarding_path(1) unless current_user.onboarding_completed?
  end

  def loader
  end

  def welcome
    return if !authenticated? || current_user.nil?
    redirect_to user_root_path if current_user.onboarding_completed?
    redirect_to onboarding_path(1) unless current_user.onboarding_completed?
  end
end
