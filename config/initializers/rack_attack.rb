# Rate Limiting Configuration — Rack::Attack
# Protects authentication endpoints from brute force attacks

if defined?(Rack::Attack)
  Rack::Attack.enabled = !Rails.env.test?

  # Throttle login attempts by IP
  throttle("logins/ip", limit: 10, period: 60) do |req|
    req.ip if req.post? && req.path == "/session"
  end

  # Throttle registration attempts by IP
  throttle("registrations/ip", limit: 5, period: 60) do |req|
    req.ip if req.post? && req.path == "/registration"
  end

  # Throttle launch signups by IP
  throttle("launch_signups/ip", limit: 10, period: 300) do |req|
    req.ip if req.post? && req.path == "/launch-signup"
  end

  # Throttle password reset requests by IP
  throttle("password_resets/ip", limit: 3, period: 300) do |req|
    req.ip if req.post? && req.path == "/users/password"
  end

  # Block suspicious IPs after 40 requests in 1 minute
  throttle("block/ip", limit: 40, period: 60) do |req|
    req.ip
  end
end
