class DocumentRole < ApplicationRecord
  include Searchable
  search_by :name

  has_many :document_users, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: true
end
