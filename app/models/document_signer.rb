class DocumentSigner < ApplicationRecord
  belongs_to :document
  belongs_to :user
  belongs_to :document_role

  validates :user, uniqueness: { scope: :document_id }

  def signed_documents
    DocumentSigner.where(signed: true)
  end

  def sign(role)
    date = Time.current
    DocumentSigner.includes(:document, :user, :document_role).update(
      signed: true, date_hour: date, role_user_signed: role
    )
  end
end
