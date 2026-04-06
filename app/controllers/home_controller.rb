class HomeController < ApplicationController
  allow_unauthenticated_access
  layout "launch", only: [ :loader ]

  def loader
  end

  def welcome
    redirect_to user_root_path if user_signed_in?
  end
end
