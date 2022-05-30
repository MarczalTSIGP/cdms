class Document < ApplicationRecord
  include Searchable

  search_by :title

  belongs_to :department
  has_many :document_signers, dependent: :destroy
  has_many :signers, through: :document_signers, source: :user

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
    dv = []
    dv <<  { name: User.human_attribute_name(:name),  identifier: :name  }
    dv <<  { name: User.human_attribute_name(:cpf),   identifier: :cpf   }
    dv <<  { name: User.human_attribute_name(:email), identifier: :email }
    dv <<  { name: User.human_attribute_name(:register_number), identifier: :register_number }

    dv
  end

  def search_non_members(term)
    User.where('unaccent(name) ILIKE unaccent(?)', "%#{term}%").order('name ASC').where.not(id: signer_ids)
  end

  def signers
    relationship.includes(:user)
  end

  def add_signer(user)
    relationship.create(user).valid?
  end

  def remove_signer(user_id)
    relationship.find_by(user_id: user_id).destroy
  end

  private

  def relationship
    send("#{self.class.name.underscore}_signers".to_sym)
  end
end
