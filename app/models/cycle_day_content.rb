class CycleDayContent < ApplicationRecord
  CARD_TYPES = %w[superpower watch_out_for mood sport nutrition fertility].freeze
  LOCALES = %w[en de].freeze
  PHASE_COLOURS = {
    1..7 => CycleCalculatorService::PHASE_META["menstrual"][:colour],
    8..14 => CycleCalculatorService::PHASE_META["follicular"][:colour],
    15..21 => CycleCalculatorService::PHASE_META["ovulation"][:colour],
    22..35 => CycleCalculatorService::PHASE_META["luteal"][:colour],
    :fallback => CycleCalculatorService::PHASE_META["menstrual"][:colour]
  }.freeze

  validates :cycle_day, presence: true,
    numericality: {in: 1..35},
    uniqueness: {scope: [:card_type, :locale]}
  validates :card_type, presence: true, inclusion: {in: CARD_TYPES}
  validates :locale, presence: true, inclusion: {in: LOCALES}

  scope :for_day, ->(day) { where(cycle_day: day) }
  scope :by_type, ->(type) { where(card_type: type) }

  def self.phase_colour(cycle_day)
    PHASE_COLOURS.each do |range, colour|
      return colour if range.is_a?(Range) && range.cover?(cycle_day)
    end
    PHASE_COLOURS[:fallback]
  end

  def self.for_forecast(cycle_day, locale: I18n.locale.to_s)
    day = cycle_day.to_i.clamp(1, 35)
    locale = locale.to_s
    records = where(cycle_day: day)
    by_locale = records.select { |r| r.locale == locale }
    return by_locale.index_by(&:card_type) if by_locale.size == CARD_TYPES.size
    records.select { |r| r.locale == "en" }.index_by(&:card_type)
  end
end
