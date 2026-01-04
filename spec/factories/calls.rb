FactoryBot.define do
  factory :call do
    table { nil }
    kind { 1 }
    status { 1 }
    message { "MyString" }
  end
end
