FactoryBot.define do
  factory :menu_item do
    tenant { nil }
    name { "MyString" }
    description { "MyText" }
    price { 1 }
    category { "MyString" }
    available { false }
  end
end
