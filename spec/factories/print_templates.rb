FactoryBot.define do
  factory :print_template do
    tenant { nil }
    store { nil }
    template_type { "MyString" }
    name { "MyString" }
    content { "MyText" }
    is_active { false }
    settings { "" }
  end
end
