allowed_hosts = [
  "seasonv2.onrender.com",
  "localhost",
  "127.0.0.1"
]
allowed_hosts += ENV.fetch("OMNIAUTH_ALLOWED_HOSTS", "").split(",").map(&:strip).reject(&:empty?)
allowed_hosts << "www.example.com" if Rails.env.test?
OmniAuth.config.allowed_hosts = allowed_hosts.uniq

# Fix omniauth-rails_csrf_protection compatibility with Rails 8.1 + iOS Safari
#
# Two issues handled here:
# 1. Rails 8.1: ActionController::RequestForgeryProtection internals changed,
#    causing valid_authenticity_token? to raise when called from OmniAuth context.
# 2. Native WebViews (iOS WKWebView / Android WebView): The session cookie is
#    frequently not sent with button_to form POSTs, causing
#    valid_authenticity_token? to return false (no exception) — which silently
#    blocks the OAuth redirect.
#
# Solution: only relax the check for requests actually coming from the native
# apps — the clients where issue #2 is real. A missing/invalid
# token from an ordinary browser is treated as a real CSRF failure and
# rejected, same as Rails' default behavior; the OAuth `state` param only
# protects the callback leg, not this initiation request.
Rails.application.config.after_initialize do
  OmniAuth::Strategy.class_eval do
    def verified_request?
      return true unless request.post? || request.put? || request.patch? || request.delete?
      return true unless respond_to?(:protect_against_forgery?) && protect_against_forgery?
      token = request.params["authenticity_token"] || request.env["HTTP_X_CSRF_TOKEN"]
      return false if token.blank?
      begin
        valid_authenticity_token?(session, token) || begin
          if native_request?
            Rails.logger.warn "[OmniAuth CSRF] Token mismatch for #{request.path} (native app). Allowing — known WKWebView cookie-loss case."
            true
          else
            false
          end
        end
      rescue => e
        Rails.logger.error "[OmniAuth CSRF] valid_authenticity_token? raised: #{e.class}: #{e.message}."
        native_request?
      end
    end

    private

    # Both native shells send a "Season Native" user-agent prefix. The old
    # "Ruby Native" value is kept for already-installed builds.
    def native_request?
      user_agent = request.env["HTTP_USER_AGENT"].to_s
      user_agent.include?("Season Native") || user_agent.include?("Ruby Native")
    end
  end
end
