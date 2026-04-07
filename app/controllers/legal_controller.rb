class LegalController < ApplicationController
  allow_unauthenticated_access

  def terms
    render layout: "application"
  end

  def privacy
    render layout: "application"
  end
end
