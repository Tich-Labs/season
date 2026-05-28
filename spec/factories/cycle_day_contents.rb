FactoryBot.define do
  factory :cycle_day_content do
    cycle_day { 1 }
    card_type { "MyString" }
    short_text { "MyText" }
    long_text { "MyText" }
    food_items { "" }
  end
end
