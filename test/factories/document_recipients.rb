FactoryBot.define do
  factory :document_recipient do
    document
    cpf { CPF.generate }
  end
end
