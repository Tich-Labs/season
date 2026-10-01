class CreateConsentRecords < ActiveRecord::Migration[8.1]
  def change
    create_table :consent_records do |t|
      t.references :beta_tester, null: false
      t.string :consent_type, null: false
      t.boolean :granted, null: false
      t.string :doc_version, null: false
      t.string :language, null: false
      t.string :text_sha256, limit: 64, null: false
      t.string :user_agent
      t.string :ip_address
      t.references :user
      t.datetime :created_at, null: false

      t.index %i[beta_tester_id consent_type created_at],
        name: "index_consent_records_on_subject_and_type"
      t.check_constraint "char_length(text_sha256::text) = 64",
        name: "consent_records_sha_length_check"
      t.check_constraint "consent_type::text = ANY (ARRAY['terms'::character varying, 'age_18'::character varying, 'health_data'::character varying, 'survey_contact'::character varying]::text[])",
        name: "consent_records_consent_type_check"
      t.check_constraint "language::text = ANY (ARRAY['de'::character varying, 'en'::character varying]::text[])",
        name: "consent_records_language_check"
    end
  end
end
