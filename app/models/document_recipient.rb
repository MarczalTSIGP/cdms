class DocumentRecipient < ApplicationRecord
  belongs_to :document
  belongs_to :profile, polymorphic: true

  validates :cpf, uniqueness: { scope: :document_id, case_sensite: false }

  def self.from_csv(file, document_id)
    CreateDocumentRecipientsFromCsv.new({ file: file, document_id: document_id }).perform
  end
end
