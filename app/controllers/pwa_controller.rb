class PwaController < ApplicationController
  allow_unauthenticated_access

  def manifest
    respond_to do |format|
      format.json { render "manifest" }
    end
  end

  def service_worker
    respond_to do |format|
      format.js { render "service_worker", content_type: "application/javascript" }
    end
  end
end
