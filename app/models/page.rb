class Page < ApplicationRecord
  validates :url, presence: true, uniqueness: true
  validates :content, presence: true
end
