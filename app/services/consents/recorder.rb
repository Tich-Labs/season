# frozen_string_literal: true

# Writes consent decisions to the append-only ledger.
#
# The controller never touches ConsentRecord directly: it hands over the
# decisions it validated and this service is the single place that decides what
# text was shown, what version it was, and when it was agreed to.
class Consents::Recorder
  Result = Data.define(:beta_tester, :records) do
    def success? = true
  end

  COMBINED_EN = "I am at least 18 years old and accept the Season Beta Terms of Participation. " \
                "I have read the Privacy Notice."

  COMBINED_DE = "Ich bin mindestens 18 Jahre alt und akzeptiere die Teilnahmebedingungen der Season Beta. " \
                "Ich habe die Datenschutzhinweise gelesen."

  # The exact wording shown to the person, per locale. Held as literals rather
  # than pulled from I18n so an approved copy edit can never silently change the
  # text a historic consent hash was taken against.
  COPY = {
    "en" => {
      "health_data" => "I explicitly consent to Season UG (haftungsbeschränkt) processing my cycle and health data " \
                  "(e.g. period, discharge, mood, symptoms, sleep, temperature) to provide me with the app's " \
                  "features (Art. 9(2)(a) GDPR). I can withdraw this consent at any time by email to " \
                  "shanel@season.vision. More in the Privacy Notice.",
      # `terms` and `age_18` share one visible sentence because the screen has a
      # single combined checkbox. Both rows hash that same sentence.
      "terms" => COMBINED_EN,
      "age_18" => COMBINED_EN,
      "survey_contact" => "You may invite me by email to surveys and interviews about the Beta. " \
                  "I can unsubscribe at any time."
    },
    "de" => {
      "health_data" => "Ich willige ausdrücklich ein, dass die Season UG (haftungsbeschränkt) meine Zyklus- und " \
                  "Gesundheitsdaten (z.B. Periode, Ausfluss, Stimmung, Symptome, Schlaf, Temperatur) verarbeitet, " \
                  "um mir die Funktionen der App bereitzustellen (Art. 9 Abs. 2 lit. a DSGVO). Ich kann diese " \
                  "Einwilligung jederzeit per E-Mail an shanel@season.vision widerrufen. Mehr in den " \
                  "Datenschutzhinweisen.",
      "terms" => COMBINED_DE,
      "age_18" => COMBINED_DE,
      "survey_contact" => "Ihr dürft mich per E-Mail zu Umfragen und Interviews rund um die Beta einladen. " \
                  "Das kann ich jederzeit abbestellen."
    }
  }.freeze

  # Keyed by the consent_type values the DB check constraint allows.
  DOC_VERSIONS = {
    "health_data" => "1.0",
    "terms" => "1.0",
    "age_18" => "1.0",
    "survey_contact" => "1.0"
  }.freeze

  def self.call(...) = new(...).call

  # Hash of the exact visible wording for this consent type, so a later audit can
  # prove the person agreed to the same sentence they were shown.
  def self.digest_for(consent_type, language)
    Digest::SHA256.hexdigest(COPY.fetch(language).fetch(consent_type))
  end

  def initialize(beta_tester:, health_data:, terms:, age_18:, survey_contact:, language:, ip: nil, user_agent: nil)
    @beta_tester = beta_tester
    @decisions = {
      "health_data" => health_data,
      "terms" => terms,
      "age_18" => age_18,
      "survey_contact" => survey_contact
    }
    @language = normalize_language(language)
    @ip = ip
    @user_agent = user_agent&.slice(0, 255)
  end

  def call
    records = @decisions.map { |type, granted| build_record(type, granted) }
    Result.new(beta_tester: @beta_tester, records: records)
  end

  private

  def normalize_language(language)
    ConsentRecord::LANGUAGES.include?(language.to_s) ? language.to_s : "en"
  end

  def build_record(consent_type, granted)
    ConsentRecord.new(
      beta_tester: @beta_tester,
      consent_type: consent_type,
      granted: granted,
      doc_version: DOC_VERSIONS.fetch(consent_type),
      language: @language,
      text_sha256: self.class.digest_for(consent_type, @language),
      ip_address: @ip,
      user_agent: @user_agent
    )
  end
end
