ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    fixtures :all

    # Sign in via the session endpoint (works for integration tests)
    def sign_in_as(user, password: "password123")
      post session_path, params: {email: user.email, password: password}
    end

    # A fresh login already grants a PIN-verified grace period (see
    # Authentication#login) — tests exercising the actual PIN-lock behavior
    # need to travel past PinProtection::PIN_TIMEOUT first.
    def travel_past_pin_grace(&block)
      travel(PinProtection::PIN_TIMEOUT + 1.minute, &block)
    end
  end
end
