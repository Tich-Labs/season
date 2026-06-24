module TurboNativeHelper
  def web_only?
    !native_app?
  end

  def native_auth_token_meta
    return unless native_app? && authenticated?

    tag.meta name: "native-auth-token", content: current_user.native_auth_token
  end

  def native_body_attributes
    return {} unless native_app?

    {data: {controller: "native", ruby_native: true}}
  end
end
