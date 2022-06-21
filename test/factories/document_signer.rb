FactoryBot.define do
  factory :document_signer do
    document
    user
    document_role
  end
end
