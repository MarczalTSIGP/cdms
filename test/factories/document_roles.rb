FactoryBot.define do
  factory :document_role do
    sequence(:name) { |n| "#{Faker::Lorem.word}-#{n}" }
    description { Faker::Lorem.sentence }
  end
end
