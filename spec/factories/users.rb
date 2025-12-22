FactoryBot.define do
  factory :user do
    tenant { nil }
    email { "MyString" }
    name { "MyString" }
    password_digest { "MyString" }
    role { 1 }
  end
end
