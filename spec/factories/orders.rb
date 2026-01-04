FactoryBot.define do
  factory :order do
    table { nil }
    status { 1 }
    people_count { 1 }
    cached_total { 1 }
    closed_at { "2026-01-03 21:36:03" }
  end
end
