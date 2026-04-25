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
      # Log the raw value so we can see what mail 2.9.0 is actually returning
      extracted = from_field.value.to_s.strip
      Rails.logger.info "[RESEND PATCH] UnstructuredField value=#{extracted.inspect}"
      # Use extracted value if it contains @, otherwise fall back to env var
      extracted.include?("@") ? extracted : ENV.fetch("RESEND_FROM_EMAIL", ENV.fetch("MAIL_FROM", "info@season.vision"))
    end
  end
end)
