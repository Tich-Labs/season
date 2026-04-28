class UserConsent < ApplicationRecord
  belongs_to :user

  VALID_CONSENT_TYPES = %w[
    health_data_processing
    symptom_tracking
    cycle_tracking
    menstrual_data
    reminders
    marketing
  ].freeze

  validates :consent_type, presence: true, inclusion: {in: VALID_CONSENT_TYPES}
  validates :user_id, uniqueness: {scope: :consent_type, conditions: -> { where(revoked_at: nil) }}

  scope :active, -> { where(revoked_at: nil) }
  scope :for_type, ->(type) { active.where(consent_type: type) }

  def active?
    revoked_at.nil?
  end

  def revoked?
    revoked_at.present?
  end

  def grant!(ip_address = nil, user_agent = nil)
    update!(
      granted_at: Time.current,
      revoked_at: nil,
      ip_address: ip_address,
      user_agent: user_agent
    )
  end

  def revoke!(ip_address = nil, user_agent = nil)
    update!(
      revoked_at: Time.current,
      ip_address: ip_address,
      user_agent: user_agent
    )
  end

  def self.granted_by?(user, consent_type)
    user.user_consents.active.exists?(consent_type: consent_type)
  end
end
