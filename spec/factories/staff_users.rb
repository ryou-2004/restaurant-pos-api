FactoryBot.define do
  factory :staff_user do
    sequence(:email) { |n| "staff#{n}@example.com" }
    name { "Staff User" }
    password { "password123" }
    role { :support_staff }
  end
end
