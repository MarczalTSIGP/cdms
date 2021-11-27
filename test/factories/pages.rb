FactoryBot.define do
  factory :page do
    content { Faker::Lorem.paragraph }
    sequence(:url) { |n| "page-#{n}" }
  end
end
