# frozen_string_literal: true

# Append-only record of a single consent decision.
#
# This is the legal ledger for the beta funnel: it is keyed to a BetaTester (a
# person who has no account yet) and is the proof Season keeps of what they
# agreed to. In-app, per-feature consent toggles for signed-in users live in
# UserConsent instead; the two serve different moments and are not duplicates.
#
# One row per (subject, consent type). Rows are never updated in place: a
# withdrawal or a re-consent writes a new row, so the full history of what a
# person agreed to, when, and in which language stays auditable. `current` is
# therefore the latest row per type, not a flag on the row.
class ConsentRecord < ApplicationRecord
  # Must stay in sync with the consent_records_consent_type_check constraint.
  TYPES = %w[terms age_18 health_data survey_contact].freeze
  LANGUAGES = %w[en de].freeze

  # Optional: lets a future authenticated User reuse the same ledger.
  belongs_to :user, optional: true
  belongs_to :beta_tester

  validates :consent_type, inclusion: {in: TYPES}
  validates :granted, inclusion: {in: [true, false]}
  validates :doc_version, presence: true
  validates :language, inclusion: {in: LANGUAGES}
  validates :text_sha256, presence: true
  validates :ip_address, length: {maximum: 45}, allow_blank: true

  scope :granted, -> { where(granted: true) }
  scope :refused, -> { where(granted: false) }

  def self.latest_for(beta_tester, consent_type)
    where(beta_tester: beta_tester, consent_type: consent_type)
      .order(created_at: :desc, id: :desc)
      .first
  end
end
