class ConfigurationsController < ApplicationController
  allow_unauthenticated_access

  def ios_v1
    render json: {
      settings: {
        "tab_bar_background_color" => "#FAF7F4",
        "tab_bar_tint_color" => "#933a35"
      },
      rules: [
        {
          patterns: ["/calendar", "/tracking", "/daily/*", "/symptoms", "/superpowers"],
          properties: {
            "presentation" => "default"
          }
        },
        {
          patterns: ["/settings/*", "/account/*"],
          properties: {
            "presentation" => "modal"
          }
        }
      ]
    }
  end

  def android_v1
    render json: {
      settings: {
        "tab_bar_background_color" => "#FAF7F4",
        "tab_bar_tint_color" => "#933a35"
      },
      rules: [
        {
          patterns: ["/calendar", "/tracking", "/daily/*", "/symptoms", "/superpowers"],
          properties: {
            "presentation" => "default"
          }
        },
        {
          patterns: ["/settings/*", "/account/*"],
          properties: {
            "presentation" => "modal"
          }
        }
      ]
    }
  end
end
