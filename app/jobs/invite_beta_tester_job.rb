# frozen_string_literal: true

# Invites a newly registered beta tester into the store's testing track.
#
# - iOS  → adds the tester to the App Store Connect external testing group
#          and triggers the TestFlight invitation email.
# - Android → the Google Play Developer API adds the tester to the closed-testing
#          track (Google emails the invite link); when that API isn't configured,
#          the tester is emailed the self-serve Google Group + Play links instead
#          of being left to wait out Google's group → Play propagation delay.
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
    if BetaTester.testflight_public_link.present?
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
    # Preferred: the Play Developer API emails the tester an invite link
    # immediately, so there is no group → Play propagation delay to wait out.
    if GooglePlayClosedTestingService.configured?
      GooglePlayClosedTestingService.invite(beta_tester)
      beta_tester.update!(status: "invited")
      return
    end

    # Fallback: self-serve Google Group mode. A consumer Google Group has no
    # API to add members and access takes a while to activate in Play, so email
    # the group + Play links rather than leaving the tester on the confirmation
    # page to wait.
    if ENV["GOOGLE_PLAY_GROUP_URL"].present? || ENV["GOOGLE_PLAY_OPEN_TESTING_URL"].present?
      BetaInviteMailer.android_group_links(beta_tester).deliver_later
      beta_tester.update!(status: "invited")
      return
    end

    Rails.logger.warn("[InviteBetaTesterJob] skipped #{beta_tester.id} — Google Play is not configured")
  rescue GooglePlayClosedTestingService::Error => e
    Rails.logger.error("[InviteBetaTesterJob] Android invite failed for #{beta_tester.id}: #{e.message}")
    raise
  end
end
