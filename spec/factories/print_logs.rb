FactoryBot.define do
  factory :print_log do
    tenant { nil }
    store { nil }
    order { nil }
    print_template { nil }
    printed_at { "2025-12-30 15:11:16" }
    status { "MyString" }
    error_message { "MyText" }
    printer_name { "MyString" }
  end
end
