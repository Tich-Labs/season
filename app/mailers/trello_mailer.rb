class TrelloMailer < ApplicationMailer
  # Sends a new Feedback record as a card to the appropriate Trello list.
  # Each feedback type maps to a separate Trello list so cards land pre-sorted.
  #
  # Trello reads the email subject as the card title and the body as the card
  # description. The reply-to is set to the submitter's email so you can reply
  # directly from Trello's card view.
  #
  # Required ENV vars (set in Render → Environment):
  #   TRELLO_FEEDBACK_EMAIL  — "Email cards to this list" address for Feedback list
  #   TRELLO_BUGS_EMAIL      — same for Bugs list
  #   TRELLO_SUPPORT_EMAIL   — same for Support list
  #
  # If a specific list address is missing, falls back to TRELLO_FEEDBACK_EMAIL.
  # If none are set, the mailer is a no-op (returns without sending).

  EMOJI = {
    "feedback" => "💬",
    "bug_report" => "🐛",
    "support" => "🆘"
  }.freeze

  TYPE_LABEL = {
    "feedback" => "Feedback",
    "bug_report" => "Bug Report",
    "support" => "Support"
  }.freeze

  def card(feedback)
    @feedback = feedback
    @user = feedback.user
    @type_label = TYPE_LABEL[feedback.type] || feedback.type.humanize
    @emoji = EMOJI[feedback.type] || "📩"
    @has_media = feedback.media.attached?

    to_address = trello_address_for(feedback.type)
    return if to_address.blank?

    # Attach the screenshot or audio recording so Trello creates a card attachment.
    if @has_media
      feedback.media.blob.open do |tempfile|
        attachments[feedback.media.blob.filename.to_s] = {
          mime_type: feedback.media.blob.content_type,
          content: tempfile.read
        }
      end
    end

    mail(
      to: to_address,
      from: "Season App <info@season.vision>",
      reply_to: @user.email,
      subject: "#{@emoji} #{@type_label} — #{@user.email}: #{feedback.message.truncate(55)}"
    )
  end

  private

  def trello_address_for(type)
    case type
    when "feedback" then ENV["TRELLO_FEEDBACK_EMAIL"]
    when "bug_report" then ENV["TRELLO_BUGS_EMAIL"]
    when "support" then ENV["TRELLO_SUPPORT_EMAIL"]
    end.presence || ENV["TRELLO_FEEDBACK_EMAIL"].presence
  end
end
