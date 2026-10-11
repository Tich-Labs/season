class HomeController < ApplicationController
  allow_unauthenticated_access
  layout "launch", only: [:loader, :app, :welcome]

  def app
    authenticated? ? redirect_to(after_sign_in_path) : redirect_to(welcome_path)
  end

  def loader
  end

  def welcome
  end
end
