class CyclePhaseContent < ApplicationRecord
  DIETARY_PREFERENCES = %w[None Vegetarian Vegan Pollotaric Pescetarian].freeze

  validates :phase, :locale, presence: true
  validates :phase, uniqueness: {scope: [:locale, :dietary_preference]}
  validates :dietary_preference, inclusion: {in: DIETARY_PREFERENCES + [""]}, allow_blank: true

  def self.for(phase, locale = "en", dietary_preference: "")
    find_by(phase: phase, locale: locale, dietary_preference: dietary_preference) ||
      find_by(phase: phase, locale: locale, dietary_preference: "") ||
      find_by(phase: phase, locale: "en", dietary_preference: "")
  end
end
