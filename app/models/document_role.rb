class DocumentRole < ApplicationRecord
  include Searchable
  search_by :name

  has_many :document_signers, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: true
end
