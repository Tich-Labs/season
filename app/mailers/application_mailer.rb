class ApplicationMailer < ActionMailer::Base
  default from: "Season App <#{ENV.fetch("RESEND_FROM_EMAIL", "info@season.vision")}>"
  layout "mailer"

  private

  def mail(headers = {}, &block)
    message = super
    Rails.logger.info "ActionMailer outgoing mail from=#{Array(message.from).join(", ")} to=#{Array(message.to).join(", ")} subject=#{message.subject}"
    message
  end
end
