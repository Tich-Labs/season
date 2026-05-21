class PwaController < ApplicationController
  skip_before_action :verify_authenticity_token
  allow_unauthenticated_access
  skip_before_action :authenticate_via_token

  def manifest
    render "pwa/manifest", format: :json, layout: false
  end

  def service_worker
    render "pwa/service-worker", format: :js, layout: false
  end
end
