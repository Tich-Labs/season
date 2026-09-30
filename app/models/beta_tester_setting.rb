class BetaTesterSetting < ApplicationRecord
  # The link text is inserted into the label at the {LINK} placeholder, so
  # the admin can reword the sentence and reposition the link independently.
  # The default renders exactly as "I have read the [Beta Test Information]
  # and agree to participate." — matching the reference design.
  DEFAULT_CONSENT_LABEL = "I have read the {LINK} and agree to participate."
  DEFAULT_CONSENT_LINK_TEXT = "Beta Test Information"

  # Placeholder until the Beta information page exists — "#" goes nowhere, so
  # there is no 404. Set a real path from the admin consent-copy editor when
  # the copy is ready.
  DEFAULT_CONSENT_URL = "#"

  validates :consent_label, presence: true
  validates :consent_link_text, presence: true
  validates :consent_url, presence: true

  # The admin edits a single row; `.current` always returns one, seeded or
  # lazily created, so the /beta form never has to guard for a missing record.
  def self.current
    first || create!(
      consent_label: DEFAULT_CONSENT_LABEL,
      consent_link_text: DEFAULT_CONSENT_LINK_TEXT,
      consent_url: DEFAULT_CONSENT_URL
    )
  rescue ActiveRecord::RecordNotUnique
    first
  end

  # The consent sentence with the link phrase substituted in, as HTML-safe
  # segments the view can interleave the real link into. Falls back to the
  # plain label (link appended after) if the admin's text has no {LINK}.
  def consent_label_parts
    label = consent_label.to_s
    if label.include?("{LINK}")
      label.split("{LINK}", 2)
    else
      [label, ""]
    end
  end
end
