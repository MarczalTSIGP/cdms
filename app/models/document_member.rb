class DocumentMember < ApplicationRecord
  include Searchable
  search_by :cpf

  validates :name, presence: true, length: { minimum: 2 }
  validates :cpf, :email, uniqueness: { case_sensitive: false }
  validates_email_format_of :email, message: I18n.t('errors.messages.invalid')
  validates_cpf_format_of :cpf, message: I18n.t('errors.messages.invalid')
end
