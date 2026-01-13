FactoryBot.define do
  factory :table do
    number { 1 }
    token { "MyString" }
    access_mode { 1 }
    pin_digest { "MyString" }
    pin_rotated_at { "2026-01-03 21:35:57" }
    last_used_at { "2026-01-03 21:35:58" }
  end
end
