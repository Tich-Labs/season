# frozen_string_literal: true

module TesterTourHelper
  # Returns the locale-appropriate screenshot for a tour slide, falling back
  # to the English capture until a localized one (e.g. `calendar-de.png`) is
  # added. Screenshots live in app/assets/images/tester_tour/.
  def tester_tour_image(name)
    localized = "tester_tour/#{name}-#{I18n.locale}.png"
    fallback = "tester_tour/#{name}.png"
    path = Rails.root.join("app/assets/images", localized).exist? ? localized : fallback
    image_path(path)
  end
end
