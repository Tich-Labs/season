class HomeController < ApplicationController
  allow_unauthenticated_access
  layout "launch", only: [:loader, :app, :countdown, :welcome]

  def app
    if authenticated?
      if current_user.onboarding_completed?
        redirect_to user_root_path
      else
        redirect_to onboarding_path(1)
      end
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
