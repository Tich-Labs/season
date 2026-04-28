Rails.application.config.session_store :cookie_store,
  key: "_season_session",
  same_site: :lax,
  expire_after: 7.days,
  httponly: true,
  secure: Rails.env.production?
