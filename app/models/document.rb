class Document < ApplicationRecord
  include Searchable
  search_by :title

  belongs_to :department

  enum category: { declaration: 'declaration', certification: 'certification' }, _suffix: :category

  validates :category, inclusion: { in: Document.categories.values }
  validates :title, :front_text, :back_text, :department_id, presence: true

  def variables=(variables)
    validate :json_format
    variables = JSON.parse(variables) if variables.is_a?(String)

    super(variables)
  end

  def self.human_categories
    categories.each_with_object({}) do |(key, _value), obj|
      obj[I18n.t("enums.categories.#{key}")] = key
    end
  end

  def is_json?
    begin
      !!JSON.parse(self)
    rescue
      false
    end
  end

  protected

  def json_format
    errors[:base] << "incorrect variable format" unless json.is_json?
  end
end
