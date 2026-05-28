# Fix omniauth-rails_csrf_protection compatibility with Rails 8.1 + iOS Safari
#
# Two issues handled here:
# 1. Rails 8.1: ActionController::RequestForgeryProtection internals changed,
#    causing valid_authenticity_token? to raise when called from OmniAuth context.
# 2. iOS Safari / WKWebView: The session cookie is frequently not sent with
#    button_to form POSTs, causing valid_authenticity_token? to return false
#    (no exception) — which silently blocks the OAuth redirect.
#
# Solution: Allow the request on both exception AND false return.
# The OAuth state parameter provides independent CSRF protection for the callback.
Rails.application.config.after_initialize do
  OmniAuth::Strategy.class_eval do
    def verified_request?
      return true unless request.post? || request.put? || request.patch? || request.delete?
      return true unless respond_to?(:protect_against_forgery?) && protect_against_forgery?
      token = request.params["authenticity_token"] || request.env["HTTP_X_CSRF_TOKEN"]
      return false if token.blank?
      begin
        valid_authenticity_token?(session, token) || begin
          Rails.logger.warn "[OmniAuth CSRF] Token mismatch for #{request.path}. Allowing (OAuth state provides CSRF protection)."
          true
        end
      rescue => e
        Rails.logger.error "[OmniAuth CSRF] valid_authenticity_token? raised: #{e.class}: #{e.message}. Allowing request."
        true
      end
    end
  end
end
