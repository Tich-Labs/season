Rails.application.config.middleware.use OmniAuth::Builder do
  if ENV["GOOGLE_CLIENT_ID"].present? && ENV["GOOGLE_CLIENT_SECRET"].present?
    provider :google_oauth2,
      ENV["GOOGLE_CLIENT_ID"],
      ENV["GOOGLE_CLIENT_SECRET"],
      {
        scope: "email,profile",
        prompt: "select_account",
        image_aspect_ratio: "square",
        image_size: 50
      }
  end

  if ENV["FACEBOOK_APP_ID"].present? && ENV["FACEBOOK_APP_SECRET"].present?
    provider :facebook,
      ENV["FACEBOOK_APP_ID"],
      ENV["FACEBOOK_APP_SECRET"],
      scope: "email",
      info_fields: "email,name"
  end

  if ENV["APPLE_CLIENT_ID"].present? && ENV["APPLE_CLIENT_SECRET"].present?
    provider :apple,
      ENV["APPLE_CLIENT_ID"],
      ENV["APPLE_CLIENT_SECRET"],
      scope: "email name"
  end
end

OmniAuth.config.allowed_request_methods = [:get, :post]
OmniAuth.config.silence_get_warning = true
