class TrelloMailer < ApplicationMailer
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

    to_address = ENV["TRELLO_EMAIL"]
    return if to_address.blank?

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
      from: "Season App <#{ENV.fetch("RESEND_FROM_EMAIL", "info@season.vision")}>",
      reply_to: @user.email,
      subject: "#{@emoji} #{@type_label} — #{@user.email}: #{feedback.message.truncate(55)}"
    )
  end
end
