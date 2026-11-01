module CalendarHelper
  # Returns the ISO week number for a given date
  def iso_week_number(date)
    date.strftime("%V").to_i
  end

  # Returns true if this is the first day of the ISO week (Monday)
  def first_day_of_week?(date)
    date.cwday == 1
  end

  # Event date card text, e.g. "Mon. Jan 1st 2026" (en) / "Mo., 1. Jan 2026" (de).
  # The day-of-month suffix is locale-specific, so it is interpolated into the
  # date.formats.event_card pattern before strftime runs.
  def event_card_date(date)
    day = t("date.ordinal_day", day: date.day, ordinal: date.day.ordinalize)
    l(date, format: t("date.formats.event_card", day: day))
  end

  # Single-letter Mon-Sun day initials, matching Figma / the main calendar.
  # Used by any weekday-header row that follows /calendar's convention.
  def weekday_initials
    I18n.t("date.day_initials")
  end

  # A month can need 6 calendar rows (e.g. a 31-day month starting on a
  # Saturday) but the screen only has room for 5. Cap it: while we're still
  # in the row holding reference_date, show the first 5 weeks; once that
  # row's date range has passed, drop it and show the last 5 weeks instead.
  # Either way only 5 rows are ever returned. Callers own how they pick
  # reference_date — this only owns the capping mechanic.
  def cap_calendar_weeks(dates, reference_date)
    weeks = dates.each_slice(7).to_a
    return dates unless weeks.size > 5

    in_first_week = weeks.first.include?(reference_date)
    (in_first_week ? weeks.first(5) : weeks.last(5)).flatten
  end
end
