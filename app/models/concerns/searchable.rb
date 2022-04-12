module Searchable
  extend ActiveSupport::Concern

  module ClassMethods
    attr_reader :fields

    private

    def search_by(*fields)
      @fields = []
      fields.each do |field|
        field.class == Symbol ? @fields.push({ field => { case_sensitive: false } }) : @fields.push(field)
      end
    end
  end

  included do
    def self.search(term)
      where(@fields.map { |field| compare(field, term) }.join(' OR '))
    end
  end
end

private
def compare(field, term)
  key = field.keys[0]
  operator = field[key][:case_sensitive] ? 'LIKE' : 'ILIKE'
  "#{key} #{operator} '%#{term}%'"
end
