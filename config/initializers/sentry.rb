if ENV["SENTRY_DSN"].present?
  Sentry.init do |config|
    config.dsn = ENV["SENTRY_DSN"]
    config.breadcrumbs_logger = [:active_support_logger, :http_logger]
    config.enable_tracing = false

    # Never send user PII to Sentry. This is a health app — request bodies,
    # headers, cookies and user email/IP could all contain health data.
    config.enable_pii = false
    config.send_default_pii = false

    config.traces_sample_rate = 0.1

    config.excluded_exceptions += [
      "ActionController::RoutingError",
      "ActiveRecord::RecordNotFound"
    ]

    # Defense in depth: even with PII off, strip the request/user interfaces
    # before anything leaves the box. Rails filter_parameters already scrubs
    # the log breadcrumbs; this covers the rest.
    config.before_send = lambda do |event, _hint|
      if event.request
        event.request.data = nil
        event.request.cookies = nil
        event.request.headers = nil
        event.request.query_string = nil
        event.request.env = nil
      end

      if event.user
        event.user.email = nil
        event.user.ip_address = nil
      end

      event
    end
  end
end
