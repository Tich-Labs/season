class LaunchController < ApplicationController
  layout "launch"
  allow_unauthenticated_access

  def index
    # Render launch screen - redirect handled by JavaScript in view
  end
end
