class PeriodStart < ApplicationRecord
  belongs_to :user

  validates :started_on, presence: true

  scope :ordered, -> { order(started_on: :asc) }

  def self.chronological
    order(started_on: :asc)
  end

  def self.reverse_chronological
    order(started_on: :desc)
  end

  def self.recent(limit = 6)
    reverse_chronological.limit(limit)
  end
end
