class ApplicationMailer < ActionMailer::Base
  default from: "Season App <#{ENV.fetch("MAIL_FROM", "info@season.vision")}>"
  layout "mailer"

  private

  # Builds the mail in the recipient's language, not the language of whatever
  # process enqueued or delivered it (jobs run outside any request locale).
  def with_recipient_locale(user, &block)
    I18n.with_locale(user.language.presence || I18n.default_locale, &block)
  end

  def mail(headers = {}, &block)
    message = super
    Rails.logger.info "ActionMailer outgoing mail from=#{Array(message.from).join(", ")} to=#{Array(message.to).join(", ")} subject=#{message.subject}"
    message
  end
end
