FactoryBot.define do
  factory :store do
    tenant { nil }
    name { "MyString" }
    address { "MyString" }
    phone { "MyString" }
    active { false }
  end
end
