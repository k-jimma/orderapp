FactoryBot.define do
  factory :item do
    name { "MyString" }
    price { 1 }
    category { nil }
    is_available { false }
  end
end
