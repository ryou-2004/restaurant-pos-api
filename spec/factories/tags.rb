FactoryBot.define do
  factory :tag do
    tenant
    sequence(:name) { |n| "タグ#{n}" }
  end
end
