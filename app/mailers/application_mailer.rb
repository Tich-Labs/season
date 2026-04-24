class ApplicationMailer < ActionMailer::Base
  default from: "Season App <#{ENV.fetch("MAIL_FROM", "info@season.vision")}>"
  layout "mailer"

  private

  def mail(headers = {}, &block)
    message = super
    Rails.logger.info "ActionMailer outgoing mail from=#{Array(message.from).join(", ")} to=#{Array(message.to).join(", ")} subject=#{message.subject}"
    message
  end
end
