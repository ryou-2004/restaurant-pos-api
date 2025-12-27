FactoryBot.define do
  factory :table do
    tenant
    store
    sequence(:number) { |n| "T#{n}" }
    capacity { 4 }
    status { :available }
  end
end
