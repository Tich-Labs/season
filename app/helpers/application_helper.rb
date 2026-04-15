module ApplicationHelper
  # Returns :new_moon, :full_moon, or nil for a given Date.
  # Uses Julian Day 2451549.5 (2000-01-06) as a known new moon reference.
  # Synodic month = 29.53059 days.
  def moon_phase(date)
    days = (date.jd - 2451549.5) % 29.53059
    days += 29.53059 if days < 0
    return :new_moon if days <= 1.5 || days >= 28.0
    return :full_moon if days.between?(13.5, 15.5)
    nil
  end
end
