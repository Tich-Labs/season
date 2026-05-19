class ApplicationController < ActionController::Base
  include Authentication
  include TurboNativeDetection
end
