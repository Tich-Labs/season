class CycleEntry < ApplicationRecord
  belongs_to :user
  PHASES = %w[menstrual follicular ovulation luteal].freeze
  SEASONS = %w[winter spring summer autumn].freeze
  validates :date, presence: true
  validates :phase, presence: true, inclusion: {in: PHASES}
  scope :for_month, ->(year, month) {
    where(date: Date.new(year, month, 1)..Date.new(year, month, -1))
  }
  scope :ordered, -> { order(:date) }
end
