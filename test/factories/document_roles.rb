FactoryBot.define do
  factory :document_role do
    name { "#{Faker::Job.position} #{Faker::Job.field}" }
    description { Faker::Job.title }
  end
end
