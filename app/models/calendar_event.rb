class CalendarEvent < ApplicationRecord
  belongs_to :user
  validates :title, :date, presence: true
  scope :for_date, ->(date) { where(date: date) }
  scope :ordered, -> { order(:start_time) }

  # Combines the date-only `date`/`end_date` columns with the time-only
  # `start_time`/`end_time` columns into real timestamps -- Google Calendar
  # (and anything else that needs a single instant) wants one datetime, not
  # a separate date + time-of-day pair. Falls back to midnight on the date
  # when no time was set (e.g. an all-day-style entry).
  def starts_at
    combine(date, start_time)
  end

  def ends_at
    combine(end_date || date, end_time || start_time)
  end

  private

  def combine(on_date, at_time)
    return on_date&.to_time unless on_date && at_time
    Time.zone.local(on_date.year, on_date.month, on_date.day, at_time.hour, at_time.min, at_time.sec)
  end
end
