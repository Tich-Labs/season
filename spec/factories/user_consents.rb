FactoryBot.define do
  factory :user_consent do
    user { nil }
    consent_type { "MyString" }
    granted_at { "2026-04-28 15:16:32" }
    revoked_at { "2026-04-28 15:16:32" }
    ip_address { "MyString" }
    user_agent { "MyString" }
  end
end
