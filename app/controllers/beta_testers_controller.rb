class BetaTestersController < ApplicationController
  allow_unauthenticated_access
  layout "beta"

  # Recruited by direct link only — keep it out of search indexes.
  before_action :set_noindex

  def new
    @beta_tester = BetaTester.new
    @setting = BetaTesterSetting.current
  end

  def create
    @beta_tester = BetaTester.new(beta_tester_params)
    @setting = BetaTesterSetting.current

    if @beta_tester.save
      @registered = true
      render :new, status: :ok
    else
      # The model normalizes the email to lowercase and checks uniqueness
      # case-insensitively, so a resubmit with any capitalisation is caught
      # here rather than by a separate pre-save lookup. The unique index on
      # beta_testers.email is the backstop against a race between two posts.
      #
      # A duplicate is a terminal outcome, not a form error: the view swaps
      # the form for an "already on the list" state, so this responds 200 —
      # 422 would tell the browser the submission failed and invite a retry
      # that cannot succeed.
      @already_registered = @beta_tester.errors.details[:email].to_a.any? { |d| d[:error] == :taken }
      render :new, status: (@already_registered ? :ok : :unprocessable_content)
    end
  end

  private

  def set_noindex
    response.set_header("X-Robots-Tag", "noindex, nofollow")
  end

  def beta_tester_params
    params.expect(beta_tester: [:name, :email, :platform, :beta_consent])
  end
end
