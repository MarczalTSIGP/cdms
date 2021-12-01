class DocumentRole < ApplicationRecord
  include Searchable
  search_by :name
  validates :name, presence: true, uniqueness: true
end
