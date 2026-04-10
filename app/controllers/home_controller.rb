class HomeController < ApplicationController
  allow_unauthenticated_access
  layout "launch", only: [:loader, :app, :countdown, :welcome]

  def app
    if authenticated?
      step = current_user.first_incomplete_onboarding_step
      step ? redirect_to(onboarding_path(step)) : redirect_to(user_root_path)
    else
      redirect_to welcome_path
    end
  end

  def loader
  end

  def welcome
  end

  def countdown
  end
end
