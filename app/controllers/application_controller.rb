class ApplicationController < ActionController::Base
  # include Authentication # TEMP: disabled for dev preview
  # Pagy::Backend - loaded in admin controller when needed

  # TEMP: Suspend auth for dev preview
  helper_method :authenticated?, :current_user
  def authenticated?
    true
  end

  def current_user
    nil
  end

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  # allow_browser versions: :modern
end
