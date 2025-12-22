FactoryBot.define do
  factory :payment do
    tenant { nil }
    order { nil }
    payment_method { 1 }
    amount { 1 }
    status { 1 }
    paid_at { "2025-12-22 12:08:17" }
  end
end
