FactoryBot.define do
  factory :subscription do
    tenant { nil }
    plan { 1 }
    realtime_enabled { false }
    polling_enabled { false }
    max_stores { 1 }
    expires_at { "2025-12-22 12:04:52" }
  end
end
