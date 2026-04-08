class PwaController < ApplicationController
  allow_unauthenticated_access

  def manifest
    render layout: false, file: "manifest", content_type: "application/json"
  end

  def service_worker
    render layout: false, file: "service-worker", content_type: "application/javascript"
  end
end
