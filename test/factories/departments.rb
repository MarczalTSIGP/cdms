FactoryBot.define do
  factory :department do
    name { Faker::Company.name }
    description { Faker::Lorem.sentence(word_count: 100) }
    initials { Faker::Name.initials(number: 5) }
    local { Faker::Address.city }
    phone { Faker::PhoneNumber.phone_number }
    email { Faker::Internet.unique.email }
  end
end
