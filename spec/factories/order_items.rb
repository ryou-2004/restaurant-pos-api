FactoryBot.define do
  factory :order_item do
    order { nil }
    menu_item { nil }
    quantity { 1 }
    unit_price { 1 }
    notes { "MyText" }
  end
end
