FactoryBot.define do
  factory :kitchen_queue do
    tenant { nil }
    order { nil }
    status { 1 }
    priority { 1 }
    estimated_cooking_time { 1 }
    started_at { "2025-12-22 12:08:12" }
    completed_at { "2025-12-22 12:08:12" }
  end
end
