class CycleDayContent < ApplicationRecord
  CARD_TYPES = %w[superpower watch_out_for mood sport nutrition fertility].freeze
  PHASE_COLOURS = {
    1..7 => "#933a35",  # Menstruation / Winter
    8..14 => "#7a8c6e",  # Follicular / Spring
    15..21 => "#4a5e4a",  # Ovulation / Summer
    22..35 => "#b07070",  # Luteal / Autumn
    :fallback => "#933a35"
  }.freeze

  validates :cycle_day, presence: true,
    numericality: {in: 1..35},
    uniqueness: {scope: :card_type}
  validates :card_type, presence: true, inclusion: {in: CARD_TYPES}

  scope :for_day, ->(day) { where(cycle_day: day) }
  scope :by_type, ->(type) { where(card_type: type) }

  def self.phase_colour(cycle_day)
    PHASE_COLOURS.each do |range, colour|
      return colour if range.is_a?(Range) && range.cover?(cycle_day)
    end
    PHASE_COLOURS[:fallback]
  end

  def self.for_forecast(cycle_day)
    day = cycle_day.to_i.clamp(1, 35)
    where(cycle_day: day).index_by(&:card_type)
  end
end
