FactoryBot.define do
  factory :order_item do
    order { nil }
    item { nil }
    quantity { 1 }
    unit_price { 1 }
    status { 1 }
    note { "MyText" }
  end
end
