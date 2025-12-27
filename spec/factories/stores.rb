FactoryBot.define do
  factory :store do
    association :tenant
    sequence(:name) { |n| "テスト店舗#{n}" }
    address { "東京都渋谷区道玄坂1-1-1" }
    phone { "03-1234-5678" }
    active { true }
  end
end
