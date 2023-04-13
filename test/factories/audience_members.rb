FactoryBot.define do
  factory :audience_member do
    name { Faker::Name.unique.name }
    email { Faker::Internet.unique.email }
    cpf { CPF.generate(true) }
  end
end
