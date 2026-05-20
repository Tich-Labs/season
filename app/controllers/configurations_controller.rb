class ConfigurationsController < ApplicationController
  allow_unauthenticated_access only: [:ios_v1]

  def ios_v1
    render json: {
      settings: {},
      rules: [
        {
          patterns: ["/calendar", "/daily/*"],
          properties: {pull_to_refresh_enabled: true}
        },
        {
          patterns: ["/settings/*", "/symptoms/new", "/symptoms/edit"],
          properties: {context: "modal"}
        }
      ]
    }
  end
end
