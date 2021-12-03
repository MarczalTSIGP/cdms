class Document < ApplicationRecord
  include Searchable
  search_by :title

  belongs_to :department

  enum category: { declaration: 'declaration', certification: 'certification' }, _suffix: :category

  validates :category, inclusion: { in: Document.categories.values }
  validates :title, :front_text, :back_text, :department_id, presence: true

  VARIABLES_JSON_SCHEMA = {
    type: Array,
    properties: {
      name: { type: String, required: true },
      identifier: { type: String, required: true }
    }
  }.freeze
  validates :variables, json: { schema: VARIABLES_JSON_SCHEMA }

  USERS_JSON_SCHEMA = {
    type: Array,
    properties: {
      id: { type: Integer, required: true, unique: true },
      name: { type: String, required: true },
      cpf: { type: String, required: true }
    }
  }.freeze
  validates :users, json: { schema: USERS_JSON_SCHEMA }

  def variables=(variables)
    variables = JSON.parse(variables) if variables.is_a?(String)
    super(variables)
  end

  def users=(users)
    users = JSON.parse(users) if users.is_a?(String)
    super(users)
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

  def add_user(user_id)
    user = User.find(user_id)
    users << user.as_json(only: [:id, :name, :cpf])
    save
  end

  def remove_user(user_id)
    user = User.find(user_id)
    users.delete(user.as_json(only: [:id, :name, :cpf]))
    save
  end

  def search_non_document_users(term)
    user_ids = users.map { |user| user['id'] }
    User.where('unaccent(name) ILIKE unaccent(?)', "%#{term}%").order('name ASC').where.not(id: user_ids)
  end
end
