class AudienceMember < ApplicationRecord
  include Searchable
  search_by :name

  has_many :document_recipients, as: :profile, dependent: :destroy
  has_many :participation_documents, through: :document_recipients, source: :document

  validates :name, presence: true, length: { minimum: 2 }
  validates :cpf, :email, uniqueness: { case_sensitive: false }
  validates_email_format_of :email, message: I18n.t('errors.messages.invalid')
  validates_cpf_format_of :cpf, message: I18n.t('errors.messages.invalid')

  def self.from_csv(file)
    CreateAudienceMembersFromCsv.new(file: file).perform
  end
end
