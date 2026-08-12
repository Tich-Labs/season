# Rate Limiting Configuration — Rack::Attack
# Protects authentication endpoints from brute force attacks

if defined?(Rack::Attack)
  Rack::Attack.enabled = Rails.env.production?

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

  Rack::Attack.blocklist("block/ip") do |req|
    Rack::Attack::Allow2Ban.filter("block-#{req.ip}", maxretry: 40, findtime: 1.minute, bantime: 1.hour) do
      true
    end
  end

  # Password-reset requests that hit the throttle above would otherwise get
  # Rack::Attack's bare "Retry later" text response, which looks like the
  # feature is broken. Send those to the same on-brand "contact support"
  # screen the controller uses for other reset-delivery failures; leave the
  # default responder in place for every other throttled endpoint.
  default_throttled_responder = Rack::Attack.throttled_responder

  Rack::Attack.throttled_responder = lambda do |req|
    if req.path == "/users/password"
      [302, {"Location" => Rails.application.routes.url_helpers.password_error_contact_path}, []]
    else
      default_throttled_responder.call(req)
    end
  end
end
