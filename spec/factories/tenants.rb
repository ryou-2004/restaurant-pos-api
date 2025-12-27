FactoryBot.define do
  factory :tenant do
    sequence(:name) { |n| "テストテナント#{n}" }
    sequence(:subdomain) { |n| "test-tenant-#{n}" }

    # サブスクリプションを自動作成
    after(:create) do |tenant|
      create(:subscription, tenant: tenant) unless tenant.subscription.present?
    end
  end
end
