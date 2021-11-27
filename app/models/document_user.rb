class DocumentUser < ApplicationRecord
  include Roleable

  belongs_to :document
  belongs_to :user

  validates :user, uniqueness: { scope: :document_id }
end
