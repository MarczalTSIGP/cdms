class DocumentUser < ApplicationRecord
  belongs_to :document
  belongs_to :user
  belongs_to :document_role

  validates :user, uniqueness: { scope: :document_id }
end
