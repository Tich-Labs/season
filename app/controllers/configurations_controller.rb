class ConfigurationsController < ApplicationController
  allow_unauthenticated_access
  allow_pin_bypass

  def ios_v1
    render json: {
      rules: [
        {
          patterns: ["/calendar", "/calendar/appointments", "/calendar/weekly", "/tracking", "/daily/*", "/symptoms", "/superpowers"],
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
          patterns: ["/calendar", "/calendar/appointments", "/calendar/weekly", "/tracking", "/daily/*", "/symptoms", "/superpowers"],
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
