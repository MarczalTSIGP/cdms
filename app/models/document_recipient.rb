class DocumentRecipient < ApplicationRecord
  belongs_to :document
  belongs_to :profile, polymorphic: true

  validates :cpf, uniqueness: { scope: :document_id, case_sensite: false }
end
