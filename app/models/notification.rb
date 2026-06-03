class Notification < ApplicationRecord
  belongs_to :user

  validates :title, :notification_type, presence: true
  validates :notification_type, inclusion: {in: %w[info appointment reminder alert success],
                                            message: :invalid_notification_type}

  scope :unread, -> { where(read_at: nil) }
  scope :read, -> { where.not(read_at: nil) }
  scope :recent, -> { order(created_at: :desc) }
  scope :by_type, ->(type) { where(notification_type: type) }

  def read?
    read_at.present?
  end

  def unread?
    read_at.nil?
  end

  def mark_as_read
    update(read_at: Time.zone.now) if unread?
  end

  def mark_as_unread
    update(read_at: nil) if read?
  end
end
