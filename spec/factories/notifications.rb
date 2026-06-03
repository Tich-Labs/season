FactoryBot.define do
  factory :notification do
    user { nil }
    title { "MyString" }
    description { "MyText" }
    notification_type { "MyString" }
    read_at { "2026-06-03 15:10:50" }
    created_at { "2026-06-03 15:10:50" }
  end
end
