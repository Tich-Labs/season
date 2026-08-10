module CalendarHelper
  # Returns the ISO week number for a given date
  def iso_week_number(date)
    date.strftime("%V").to_i
  end

  # Returns true if this is the first day of the ISO week (Monday)
  def first_day_of_week?(date)
    date.cwday == 1
  end
end
