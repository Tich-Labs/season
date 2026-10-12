module ApplicationHelper
  # Maps the English season labels in CycleCalculatorService::PHASE_META to the
  # seasons.* i18n keys so views never render "Autumn"/"Winter" verbatim.
  SEASON_LOCALE_KEYS = {
    "Winter" => "winter",
    "Spring" => "spring",
    "Summer" => "summer",
    "Autumn" => "autumn"
  }.freeze

  # Localizes a season label ("Winter"/"Spring"/"Summer"/"Autumn"). Falls back
  # to the original string when the season is nil or unknown.
  def localized_season(season_name)
    key = SEASON_LOCALE_KEYS[season_name.to_s]
    key ? t("seasons.#{key}") : season_name
  end

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

  # Sets --phase-color CSS custom property so child elements can reference
  # it via var(--phase-color) instead of per-element inline styles.
  # Call in any view that renders phase-colored elements:
  #   <% phase_color(@phase_colour) %>
  def phase_color(hex)
    content_for(:phase_color, hex)
  end
end
