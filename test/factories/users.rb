FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "Name #{n}" }
    sequence(:register_number) { |n| "123123#{n}" }
    sequence(:username) { |n| "usarname#{n}" }
    cpf { CPF.generate }
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
