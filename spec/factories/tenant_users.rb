FactoryBot.define do
  factory :tenant_user do
    association :tenant
    sequence(:email) { |n| "user#{n}@example.com" }
    sequence(:name) { |n| "テストユーザー#{n}" }
    password { "password123" }
    role { :staff }

    # ロール別のトレイト
    trait :owner do
      role { :owner }
    end

    trait :manager do
      role { :manager }
    end

    trait :kitchen_staff do
      role { :kitchen_staff }
    end

    trait :cashier do
      role { :cashier }
    end
  end
end
