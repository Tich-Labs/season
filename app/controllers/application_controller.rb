class ApplicationController < ActionController::Base
  include Authentication
  include TurboNativeDetection
  include PinProtection
end
