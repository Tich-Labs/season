class ConfigurationsController < ApplicationController
  # GET /configurations/ios_v1.json
  def ios_v1
    config = {
      rules: [
        {
          patterns: ["/calendar", "/daily/*"],
          properties: {presentation: "default", pull_to_refresh: true}
        },
        {
          patterns: ["/settings/*", "/symptoms/new", "/symptoms/edit"],
          properties: {presentation: "modal"}
        }
      ]
    }
    render json: config
  end
end
