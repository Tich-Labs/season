module CalendarHelper
  # Returns a hash mapping dates to holiday names for the given month/year
  def holidays_for_month(year, month)
    # Using Date's built-in Easter calculation and common holidays
    holidays = {}

    # New Year's Day
    holidays[Date.new(year, 1, 1)] = "New Year's Day"

    # Easter (Western)
    easter = easter_date(year)
    holidays[easter] = "Easter Sunday"
    holidays[easter - 2.days] = "Good Friday"
    holidays[easter + 1.day] = "Easter Monday"

    # Labour Day
    holidays[Date.new(year, 5, 1)] = "Labour Day"

    # Christmas
    holidays[Date.new(year, 12, 25)] = "Christmas Day"
    holidays[Date.new(year, 12, 26)] = "Boxing Day"

    # Filter to the requested month
    holidays.select { |date, _| date.month == month }.with_indifferent_access
  end

  # Returns the ISO week number for a given date
  def iso_week_number(date)
    date.strftime("%V").to_i
  end

  # Returns true if this is the first day of the ISO week (Monday)
  def first_day_of_week?(date)
    date.cwday == 1
  end

  private

  # Calculate Easter date using the Anonymous Gregorian algorithm
  def easter_date(year)
    y = year
    a = y % 19
    b = y / 100
    c = y % 100
    d = b / 4
    e = b % 4
    f = (b + 8) / 25
    g = (b - f + 1) / 3
    h = (19 * a + b - d - g + 15) % 30
    i = c / 4
    k = c % 4
    l = (32 + 2 * e + 2 * i - h - k) % 7
    m = (a + 11 * h + 22 * l) / 451
    month = (h + l - 7 * m + 114) / 31
    day = ((h + l - 7 * m + 114) % 31) + 1
    Date.new(y, month, day)
  end
end
