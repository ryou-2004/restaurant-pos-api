FactoryBot.define do
  factory :order do
    tenant { nil }
    order_number { "MyString" }
    table_id { 1 }
    status { 1 }
    total_amount { 1 }
    notes { "MyText" }
  end
end
