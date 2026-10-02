# frozen_string_literal: true

# Invites a newly registered beta tester into the store's testing track.
#
# - iOS  → adds the tester to the App Store Connect external testing group
#          and triggers the TestFlight invitation email.
# - Android → adds the tester to the Google Play closed-testing track;
#          Google Play emails the invite link.
#
# Best-effort by design: a failure leaves the tester at "registered" so the
# admin can retry, and the underlying API calls are idempotent so Solid
# Queue's automatic retries are safe.
class InviteBetaTesterJob < ApplicationJob
  queue_as :default

  def perform(beta_tester_id)
    beta_tester = BetaTester.find_by(id: beta_tester_id)
    return unless beta_tester
    return unless beta_tester.status == "registered"

    case beta_tester.platform
    when "ios" then invite_ios(beta_tester)
    when "android" then invite_android(beta_tester)
    end
  end

  private

  def invite_ios(beta_tester)
    # Public-link mode: the tester installs via the TestFlight public link
    # shown on the confirmation page — no per-email App Store Connect API
    # invite needed (and no 100-seat limit).
    if ENV["TESTFLIGHT_PUBLIC_LINK"].present?
      beta_tester.update!(status: "invited")
      return
    end

    unless AppStoreConnectService.configured?
      Rails.logger.warn("[InviteBetaTesterJob] skipped #{beta_tester.id} — App Store Connect is not configured")
      return
    end

    AppStoreConnectService.invite(beta_tester)
    beta_tester.update!(status: "invited")
  rescue AppStoreConnectService::Error => e
    Rails.logger.error("[InviteBetaTesterJob] iOS invite failed for #{beta_tester.id}: #{e.message}")
    raise
  end

  def invite_android(beta_tester)
    # Group/closed-test link mode: testers self-join via the Google Group +
    # Play testing link shown on the confirmation page — no per-email Play
    # API invite (Google auto-admits group members to the closed test).
    if ENV["GOOGLE_PLAY_GROUP_URL"].present? || ENV["GOOGLE_PLAY_OPEN_TESTING_URL"].present?
      beta_tester.update!(status: "invited")
      return
    end

    unless GooglePlayClosedTestingService.configured?
      Rails.logger.warn("[InviteBetaTesterJob] skipped #{beta_tester.id} — Google Play is not configured")
      return
    end

    GooglePlayClosedTestingService.invite(beta_tester)
    beta_tester.update!(status: "invited")
  rescue GooglePlayClosedTestingService::Error => e
    Rails.logger.error("[InviteBetaTesterJob] Android invite failed for #{beta_tester.id}: #{e.message}")
    raise
  end
end
