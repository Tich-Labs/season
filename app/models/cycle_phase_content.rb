class CyclePhaseContent < ApplicationRecord
  validates :phase, :locale, presence: true
  validates :phase, uniqueness: {scope: :locale}

  def self.for(phase, locale = "en")
    find_by(phase: phase, locale: locale) ||
      find_by(phase: phase, locale: "en")
  end
end
