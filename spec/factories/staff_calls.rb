FactoryBot.define do
  factory :staff_call do
    tenant { nil }
    store { nil }
    table { nil }
    table_session { nil }
    status { 1 }
    call_type { "MyString" }
    resolved_at { "2025-12-31 17:20:28" }
    resolved_by_id { 1 }
    notes { "MyText" }
  end
end
