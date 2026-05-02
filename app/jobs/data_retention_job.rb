# Data Retention Job — GDPR Article 5(1)(e)
# Automatically deletes expired user data per defined retention periods.
# Run daily via Render Cron (config/recurring.yml)

class DataRetentionJob < ApplicationJob
  queue_as :default
  retry_on StandardError, attempts: 3

  # Retention periods (in years)
  CYCLE_RETENTION_YEARS = 3
  SYMPTOM_RETENTION_YEARS = 3
  CALENDAR_RETENTION_YEARS = 1
  CONSENT_RETENTION_YEARS = 3

  def perform
    Rails.logger.info "[DataRetentionJob] Starting at #{Time.zone.now}"

    deleted_counts = {
      cycle_entries: delete_old_cycle_entries,
      symptom_logs: delete_old_symptom_logs,
      calendar_events: delete_old_calendar_events,
      superpower_logs: delete_old_superpower_logs
    }

    Rails.logger.info "[DataRetentionJob] Deleted: #{deleted_counts.inspect}"
  end

  private

  def delete_old_cycle_entries
    cutoff_date = CYCLE_RETENTION_YEARS.years.ago
    CycleEntry.where("updated_at < ?", cutoff_date).delete_all
  rescue => e
    Rails.logger.error "[DataRetentionJob] Error deleting cycle entries: #{e.message}"
    0
  end

  def delete_old_symptom_logs
    cutoff_date = SYMPTOM_RETENTION_YEARS.years.ago
    SymptomLog.where("updated_at < ?", cutoff_date).delete_all
  rescue => e
    Rails.logger.error "[DataRetentionJob] Error deleting symptom logs: #{e.message}"
    0
  end

  def delete_old_calendar_events
    cutoff_date = CALENDAR_RETENTION_YEARS.years.ago
    CalendarEvent.where("updated_at < ?", cutoff_date).delete_all
  rescue => e
    Rails.logger.error "[DataRetentionJob] Error deleting calendar events: #{e.message}"
    0
  end

  def delete_old_superpower_logs
    cutoff_date = CALENDAR_RETENTION_YEARS.years.ago
    SuperpowerLog.where("updated_at < ?", cutoff_date).delete_all
  rescue => e
    Rails.logger.error "[DataRetentionJob] Error deleting superpower logs: #{e.message}"
    0
  end
end
