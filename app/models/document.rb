class Document < ApplicationRecord
  include Searchable
  search_by :title

  include Members
  build_member_methods(relationship: :signers, name: :signing_member)

  belongs_to :department
  has_many :document_signers, dependent: :destroy
  has_many :signers, through: :document_signers, source: :user

  has_many :document_recipients, dependent: :destroy

  enum category: { declaration: 'declaration', certification: 'certification' }, _suffix: :category

  validates :category, inclusion: { in: Document.categories.values }
  validates :title, :front_text, :back_text, :department_id, presence: true
  validates :variables, json: true

  def variables=(variables)
    variables = JSON.parse(variables) if variables.is_a?(String)
    super(variables)
  end

  def self.human_categories
    categories.each_with_object({}) do |(key, _value), obj|
      obj[I18n.t("enums.categories.#{key}")] = key
    end
  end

  def default_variables
    variables = [:name, :cpf, :email, :register_number]

    variables.map do |variable|
      { name: User.human_attribute_name(variable), identifier: variable }
    end
  end

  def recipients
    document_recipients.includes(:profile)
  end

  def add_recipient(cpf)
    profile = search_non_recipient(cpf)

    return false if profile.blank?

    document_recipients.create(cpf: profile.cpf, profile_id: profile.id, profile_type: profile.class.name).valid?
  end

  def remove_recipient(cpf)
    document_recipient = document_recipients.find_by(cpf: cpf)

    return false if document_recipient.blank?

    document_recipient.destroy
  end

  def search_non_recipient(cpf)
    non_recipient = document_recipients.find_by(cpf: cpf).blank?

    return non_recipient if non_recipient == false

    user = User.find_by(cpf: cpf)

    return user if user.present?

    audience_member = AudienceMember.find_by(cpf: cpf)

    return audience_member if audience_member.present?
  end
end
