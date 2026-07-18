class ConfigurationsController < ApplicationController
  allow_unauthenticated_access

  def ios_v1
    render json: {
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
