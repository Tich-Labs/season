class ApplicationJob < ActiveJob::Base
  # Automatically retry jobs that encountered a deadlock
  # retry_on ActiveRecord::Deadlocked

  # Most jobs are safe to ignore if the underlying records are no longer available
  # discard_on ActiveJob::DeserializationError

  def with_user_locale(user, &block)
    I18n.with_locale(user&.language.presence || I18n.default_locale, &block)
  end
end
