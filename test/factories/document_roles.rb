FactoryBot.define do
  factory :document_role do
    name { Faker::Job.unique.position }
    description { Faker::Job.title }
  end
end
