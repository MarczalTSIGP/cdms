class DocumentSigner < ApplicationRecord
  belongs_to :document
  belongs_to :user
  belongs_to :document_role

  validates :user, uniqueness: { scope: :document_id }

  scope :unsigned, -> { includes(:user).where(signed: false) }
  scope :signed, -> { includes(:user).where(signed: true) }

  def sign
    role = document_role.name
    date = Time.current
    update(signed: true, signed_datetime: date, signer_role: role)
  end
end
