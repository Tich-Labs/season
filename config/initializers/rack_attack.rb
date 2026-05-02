# Rate Limiting Configuration — Rack::Attack
# Protects authentication endpoints from brute force attacks
# Note: Basic configuration. Full throttling requires additional Rack::Attack setup.

if defined?(Rack::Attack)
  # Disable for tests
  Rack::Attack.enabled = !Rails.env.test?
end

