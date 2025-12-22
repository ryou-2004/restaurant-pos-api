FactoryBot.define do
  factory :tenant_user do
    tenant
    sequence(:email) { |n| "user#{n}@example.com" }
    name { "Test User" }
    password { "password123" }
    role { :staff }
  end
end
