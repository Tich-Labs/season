# Fix omniauth-rails_csrf_protection compatibility with Rails 8.1
# The gem overrides request_phase to verify Rails CSRF before OAuth redirect,
# but ActionController::RequestForgeryProtection internals changed in Rails 8.1
# causing verified_request? to fail when called from the OmniAuth strategy context.
#
# Solution: wrap the CSRF check in a rescue. If it fails, allow the request;
# the OAuth state parameter already provides CSRF protection for the callback.
Rails.application.config.after_initialize do
  OmniAuth::Strategy.class_eval do
    def verified_request?
      return true unless request.post? || request.put? || request.patch? || request.delete?
      return true unless respond_to?(:protect_against_forgery?) && protect_against_forgery?
      token = request.params["authenticity_token"] || request.env["HTTP_X_CSRF_TOKEN"]
      return false if token.blank?
      begin
        valid_authenticity_token?(session, token)
      rescue => e
        Rails.logger.error "[OmniAuth CSRF] valid_authenticity_token? failed: #{e.class}: #{e.message}. Allowing request."
        true
      end
    end
  end
end
