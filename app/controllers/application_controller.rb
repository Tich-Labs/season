class ApplicationController < ActionController::Base
  include Authentication
  # Pagy::Backend - loaded in admin controller when needed

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  # allow_browser versions: :modern
end
