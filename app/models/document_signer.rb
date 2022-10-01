class DocumentSigner < ApplicationRecord
  belongs_to :document
  belongs_to :user
  belongs_to :document_role

  validates :user, uniqueness: { scope: :document_id }

  def sign
    role = document_role.name
    date = Time.current
    DocumentSigner.update(signed: true, signed_datetime: date, signer_role: role)
  end
end
