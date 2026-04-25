Resend.api_key = ENV["RESEND_API_KEY"]

# resend gem 1.3.0 bug: Resend::Mailer#get_from calls .formatted on the from
# field, but mail 2.9.0 returns Mail::UnstructuredField (no .formatted method)
# when the from header contains a display name set via ActionMailer default_options.
# Patch until this is fixed upstream in the resend gem.
Resend::Mailer.prepend(Module.new do
  private

  def get_from(mail)
    from_field = mail[:from]
    if from_field.respond_to?(:formatted)
      from_field.formatted.first
    else
      from_field.value.to_s.strip
    end
  end
end)
