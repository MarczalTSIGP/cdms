FactoryBot.define do
  factory :document_recipient do
    document
    cpf { CPF.generate(true) }
  end

  trait :user do
    association :profile, factory: :user
  end

  trait :audience_member do
    association :profile, factory: :audience_member
  end
end
