FactoryBot.define do
  factory :document_role do
    name { Faker::Lorem.word }
    description { Faker::Lorem.sentense }
  end
end
