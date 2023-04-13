FactoryBot.define do
  factory :department_module do
    department
    name { Faker::Company.unique.name }
    description { Faker::Lorem.sentence(word_count: 100) }
  end
end
