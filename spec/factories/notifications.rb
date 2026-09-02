FactoryBot.define do
  factory :notification do
    user { nil }
    title { "Test notification" }
    description { "Test notification body" }
    # "MyString" (the default scaffold placeholder) fails
    # Notification's own inclusion validation — this factory couldn't
    # actually create a record.
    notification_type { "info" }
    read_at { nil }
  end
end
