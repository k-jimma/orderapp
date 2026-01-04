FactoryBot.define do
  factory :payment do
    amount { 1 }
    discount_amount { 1 }
    rounding_adjustment { 1 }
    received_cash { 1 }
    change { 1 }
    paid_at { "2026-01-03 21:36:18" }
    payment_method { 1 }
    status { 1 }
    note { "MyText" }
  end
end
