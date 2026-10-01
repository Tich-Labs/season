class BetaTester < ApplicationRecord
  PLATFORMS = %w[ios android web].freeze
  STATUSES = %w[registered invited active completed].freeze

  enum :status, {registered: "registered", invited: "invited", active: "active", completed: "completed"}

  # The consent ledger is append-only while the tester exists, but a tester can
  # still be erased entirely, which is what the beta disclosure promises. The
  # foreign key on consent_records.beta_tester_id otherwise blocks deletion.
  has_many :consent_records, dependent: :destroy

  before_validation :normalize_email

  validates :name, presence: true
  validates :email, presence: true,
    format: {with: URI::MailTo::EMAIL_REGEXP},
    uniqueness: {case_sensitive: false}
  validates :platform, presence: true, inclusion: {in: PLATFORMS}
  # Custom message via errors.add rather than `acceptance: {message:}` so the
  # text lives beside the other validation messages in this file.
  validate :consent_must_be_accepted

  # A blank filter means "no filter", so these return `all` explicitly rather
  # than nil — a scope body returning nil makes ActiveRecord fall back to
  # `all` anyway, which hides the intent.
  scope :for_platform, ->(platform) { platform.present? ? where(platform: platform) : all }
  scope :with_status, ->(status) { status.present? ? where(status: status) : all }
  scope :search, ->(query) {
    next all if query.blank?

    pattern = "%#{sanitize_sql_like(query.to_s.strip)}%"
    where("name ILIKE :q OR email ILIKE :q", q: pattern)
  }
  scope :newest_first, -> { order(created_at: :desc) }

  private

  def consent_must_be_accepted
    return if beta_consent?

    errors.add(:beta_consent, :accepted, message: "must be accepted before joining the beta.")
  end

  def normalize_email
    self.email = email.to_s.strip.downcase.presence
  end
end
