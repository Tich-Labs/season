# Invite Token Cleanup Job — Security: Remove expired invite tokens
# Run daily to clean up unused invites after 7 days

class CleanupExpiredInvitesJob < ApplicationJob
  queue_as :default
  retry_on StandardError, attempts: 3

  def perform
    Rails.logger.info "[CleanupExpiredInvitesJob] Starting at #{Time.zone.now}"

    # Clear expired tokens that were never used
    deleted_count = User.where.not(invite_token: nil)
      .where("invite_token_expires_at < ?", Time.zone.now)
      .update_all(invite_token: nil)

    Rails.logger.info "[CleanupExpiredInvitesJob] Cleared #{deleted_count} expired invite tokens"
  rescue => e
    Rails.logger.error "[CleanupExpiredInvitesJob] Error: #{e.message}"
    raise
  end
end
