# Rate Limiting Configuration — Rack::Attack
# Protects authentication endpoints from brute force attacks

if defined?(Rack::Attack)
  Rack::Attack.enabled = Rails.env.production?

  # Without inserting the middleware the throttles below are defined but never
  # run — the rack-attack gem doesn't add itself to the stack. Register it so
  # the rate limits actually apply in production.
  Rails.application.config.middleware.use(Rack::Attack)

  # Render polls this path continuously for the service's health check —
  # never let it count toward the IP ban threshold below.
  Rack::Attack.safelist("allow health check") do |req|
    req.path == "/up"
  end

  # Common vulnerability-scanner probe paths that have no route in this app.
  # Rejecting them here means a scanner's noise never reaches the Rails
  # router/controller stack and counts fast toward the IP ban below.
  SCANNER_PATH_PATTERN = %r{
    \.(?:php|asp|aspx|env|git|svn|htaccess|DS_Store)\z |
    \A/(?:wp-admin|wp-login|xmlrpc\.php|phpmyadmin|actuator)
  }xi

  Rack::Attack.blocklist("block scanner paths") do |req|
    req.path.match?(SCANNER_PATH_PATTERN)
  end

  Rack::Attack.throttle("logins/ip", limit: 10, period: 60) do |req|
    req.ip if req.post? && req.path == "/session"
  end

  Rack::Attack.throttle("registrations/ip", limit: 5, period: 60) do |req|
    req.ip if req.post? && req.path == "/registration"
  end

  Rack::Attack.throttle("launch_signups/ip", limit: 10, period: 300) do |req|
    req.ip if req.post? && req.path == "/launch-signup"
  end

  Rack::Attack.throttle("password_resets/ip", limit: 3, period: 300) do |req|
    req.ip if req.post? && req.path == "/users/password"
  end

  # Send a rate-limited password-reset request to the branded "already sent
  # an email, wait an hour" screen instead of Rack::Attack's raw default 429
  # text response. Every other throttle (logins, registrations, launch
  # signups) keeps that default -- only password_resets/ip has a matching
  # branded screen to redirect to.
  Rack::Attack.throttled_responder = lambda do |request|
    if request.env["rack.attack.matched"] == "password_resets/ip"
      [302, {"Location" => Rails.application.routes.url_helpers.password_error_already_reset_path}, []]
    else
      [429, {"Content-Type" => "text/plain"}, ["Retry later\n"]]
    end
  end

  Rack::Attack.blocklist("block/ip") do |req|
    Rack::Attack::Allow2Ban.filter("block-#{req.ip}", maxretry: 40, findtime: 1.minute, bantime: 1.hour) do
      true
    end
  end
end
