module Webhooks
  # Receives bounce/complaint events from Resend so error_wrong_email and
  # error_inbox_full (app/views/passwords/) have a real trigger -- previously
  # nothing in the app ever redirected to either. Bounces arrive well after
  # the request that sent the email has finished, so this can't render an
  # error screen directly; it records the bounce on the user, and
  # PasswordsController#create checks for a recent one on the *next* reset
  # attempt for that address (see there for the actual redirect).
  #
  # ASSUMPTION FLAGGED: the bounce sub-type field names below
  # (data.bounce.subType / data.bounce.type / data.bounce.message) are
  # Resend's documented shape as of when this was written, not verified
  # against a live webhook delivery -- confirm against a real payload (or
  # https://resend.com/docs/dashboard/webhooks/event-types) before relying on
  # the inbox-full vs wrong-email split in production. Every bounce still
  # gets recorded even if the sub-type can't be classified; it just falls
  # back to the more general "wrong_email" screen.
  class ResendController < ApplicationController
    allow_unauthenticated_access
    skip_forgery_protection

    def create
      ResendWebhookVerifierService.verify!(
        payload: request.raw_post,
        headers: request.headers,
        secret: ENV["RESEND_WEBHOOK_SECRET"]
      )

      case params[:type]
      when "email.bounced"
        record_bounce
      when "email.complained"
        Rails.logger.info("[Resend webhook] complaint for #{recipient_emails.inspect}")
      end

      head :ok
    rescue ResendWebhookVerifierService::VerificationError => e
      Rails.logger.warn("[Resend webhook] rejected: #{e.message}")
      head :unauthorized
    end

    private

    def record_bounce
      type = classify_bounce
      recipient_emails.each do |email|
        user = User.find_by(email: email.to_s.downcase.strip)
        user&.record_email_bounce!(type)
      end
    end

    def recipient_emails
      Array(params.dig(:data, :to))
    end

    def classify_bounce
      bounce = params.dig(:data, :bounce) || {}
      signal = [bounce[:subType], bounce[:type], bounce[:message]].compact.join(" ").downcase
      (signal.include?("mailbox") && signal.include?("full")) ? "inbox_full" : "wrong_email"
    end
  end
end
