vapid_configured = Rails.application.credentials.dig(:vapid).present? ||
  (ENV["VAPID_PUBLIC_KEY"].present? && ENV["VAPID_PRIVATE_KEY"].present?)

unless vapid_configured
  Rails.logger.warn "VAPID keys not configured. Run: rails vapid:generate, then: rails credentials:edit"
end
