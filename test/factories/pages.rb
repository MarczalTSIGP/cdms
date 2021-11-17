FactoryBot.define do
  factory :page do
    content { Faker::Lorem.paragraph }
  end
end
