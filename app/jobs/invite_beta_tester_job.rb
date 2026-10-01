# frozen_string_literal: true

# Adds a newly registered iOS beta tester to the App Store Connect external
# testing group and triggers the TestFlight invitation email.
#
# Best-effort by design: a failure leaves the tester at "registered" so the
# admin can retry, and the underlying API calls are idempotent so Solid
# Queue's automatic retries are safe.
class InviteBetaTesterJob < ApplicationJob
  queue_as :default

  def perform(beta_tester_id)
    unless AppStoreConnectService.configured?
      Rails.logger.warn("[InviteBetaTesterJob] skipped for #{beta_tester_id} — App Store Connect is not configured")
      return
    end

    beta_tester = BetaTester.find_by(id: beta_tester_id)
    return unless beta_tester
    return unless beta_tester.platform == "ios" && beta_tester.status == "registered"

    AppStoreConnectService.invite(beta_tester)
    beta_tester.update!(status: "invited")
  rescue AppStoreConnectService::Error => e
    Rails.logger.error("[InviteBetaTesterJob] failed for beta_tester #{beta_tester_id}: #{e.message}")
    raise
  end
end
