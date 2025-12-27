FactoryBot.define do
  factory :subscription do
    association :tenant
    plan { :standard }
    realtime_enabled { false }
    polling_enabled { true }
    max_stores { 5 }
    expires_at { 1.year.from_now }

    # プラン別のトレイト
    trait :basic do
      plan { :basic }
      realtime_enabled { false }
      polling_enabled { false }
      max_stores { 1 }
    end

    trait :standard do
      plan { :standard }
      realtime_enabled { false }
      polling_enabled { true }
      max_stores { 5 }
    end

    trait :enterprise do
      plan { :enterprise }
      realtime_enabled { true }
      polling_enabled { true }
      max_stores { 999 }
    end
  end
end
