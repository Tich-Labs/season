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

    # minitest 6 removed `minitest/mock`, so `Object#stub` is gone. This is a
    # minimal replacement for stubbing a class/module method:
    #
    #   stub_class_method(HTTParty, :send, ->(*args, **kwargs) { fake })
    #
    # The original method is restored when the block exits.
    def stub_class_method(target, method_name, callable)
      singleton = target.singleton_class
      own_method = singleton.method_defined?(method_name, false) ||
        singleton.private_method_defined?(method_name, false)
      original = target.method(method_name) if own_method
      singleton.send(:undef_method, method_name) if own_method
      singleton.send(:define_method, method_name) do |*args, **kwargs, &blk|
        callable.call(*args, **kwargs, &blk)
      end
      yield
    ensure
      still_own = singleton.method_defined?(method_name, false) ||
        singleton.private_method_defined?(method_name, false)
      singleton.send(:undef_method, method_name) if still_own
      singleton.send(:define_method, method_name, original) if own_method
    end
  end
end
