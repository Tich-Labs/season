class DebugController < ApplicationController
  skip_before_action :verify_authenticity_token, if: :json_request?

  def test
    render plain: "OK"
  end

  def env
    render json: {
      rails_env: Rails.env,
      eager_load: Rails.application.config.eager_load?,
      secret_key_base_set: ENV["SECRET_KEY_BASE"].present?,
      database_url_set: ENV["DATABASE_URL"].present?,
      ruby_version: RUBY_VERSION
    }
  end

  private

  def json_request?
    request.format.json?
  end
end
