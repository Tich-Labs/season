class HomeController < ApplicationController
  allow_unauthenticated_access
  layout "launch", only: [:loader, :app, :countdown, :welcome]

  def app
    authenticated? ? redirect_to(after_sign_in_path) : redirect_to(welcome_path)
  end

  def loader
  end

  def welcome
  end

  def countdown
  end
end
