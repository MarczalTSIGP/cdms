module Searchable
  extend ActiveSupport::Concern

  included do
    def self.search(term)
      where(@condition, term: "%#{term}%")
    end
  end

  module ClassMethods
    private

    def search_by(*fields)
      @condition = Condition.new(fields).to_args
    end
  end

  class Condition
    def initialize(fields)
      @fields = fields
      normalize_fields
    end

    def to_args
      @fields.map { |field| build_condition_for(field) }.join(' OR ')
    end

    private

    def normalize_fields
      @fields.map! { |field| normalize_options(field) }
    end

    def normalize_options(field)
      return field unless field.is_a?(Symbol)

      { field => { case_sensitive: false } }
    end

    def build_condition_for(field)
      field_name = field.keys[0]
      field_options = field[field_name]

      compartor = field_options[:case_sensitive] ? 'LIKE' : 'ILIKE'

      "#{field_name} #{compartor} :term"
    end
  end
end
