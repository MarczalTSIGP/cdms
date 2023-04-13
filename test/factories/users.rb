FactoryBot.define do
  factory :user do
    name { "#{Faker::Name.first_name} #{Faker::Name.middle_name} #{Faker::Name.last_name}" }
    register_number { Faker::Number.number(digits: 7) }
    username { Faker::Internet.unique.username }
    cpf { CPF.generate(true) }
    active { true }
    role { nil }
    password { 'password' }
    password_confirmation { 'password' }
  end

  trait :manager do
    role { create(:role_manager) }
  end

  trait :assistant do
    role { create(:role_assistant) }
  end
end
