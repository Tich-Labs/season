class BetaTester < ApplicationRecord
  PLATFORMS = %w[ios android web].freeze
  STATUSES = %w[registered invited active completed].freeze

  enum :status, {registered: "registered", invited: "invited", active: "active", completed: "completed"}

  # The consent ledger is append-only while the tester exists, but a tester can
  # still be erased entirely, which is what the beta disclosure promises. The
  # foreign key on consent_records.beta_tester_id otherwise blocks deletion.
  has_many :consent_records, dependent: :destroy

  # The in-app account this beta signup eventually became. Linked by email
  # when the tester signs up in the app — this is what lets the admin see a
  # tester's real usage and feedback, not just their registration.
  belongs_to :user, optional: true

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

  # Links an in-app account back to its beta signup by email, promoting the
  # tester to "active" now that they are actually using the app. Called from
  # User's after_create_commit. Idempotent and never downgrades "completed".
  def self.link_to_user!(user)
    tester = where("LOWER(email) = ?", user.email.to_s.downcase).newest_first.first
    return unless tester

    tester.update!(user: user, status: "active") unless tester.completed?
    tester
  end

  def linked? = user_id.present?

  private

  def consent_must_be_accepted
    return if beta_consent?

    errors.add(:beta_consent, :accepted, message: "must be accepted before joining the beta.")
  end

  def normalize_email
    self.email = email.to_s.strip.downcase.presence
  end
end
