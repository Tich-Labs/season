# Rate Limiting Configuration — Rack::Attack
# Protects authentication endpoints from brute force attacks

if defined?(Rack::Attack)
  Rack::Attack.enabled = !Rails.env.test?

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
end
