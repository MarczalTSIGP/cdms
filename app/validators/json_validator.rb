class JsonValidator < ActiveModel::EachValidator
  REGEX_NAME << /[{}@!#%^&*()$]/
  REGEX_IDENTIFIER << /[{}@!#%^&*_()$\s]/

  def validate_each(record, attribute, value)
    return unless value.is_a?(Array)

    record.errors.add attribute, (options[:message] || 'is not an Array')
  end

  def ambiguous_value(record, identifier, value)
    value.each do |json|
      unless identifier == json['identifier']
        record.errors.add(:identifier, I18n.t('errors.messages.taken'))
      end
    end
  end

  def validate_json(record, attribute, value)
    if value.is_a?(Array)
      value.each do |json|
        unless json.key?('name') && json.key?('identifier')
          record.errors.add attribute, (options[:message] || "element #{json} with invalid format")
        end
      end
    end
  end

  def validate_name(record, attribute, value)
    value.each do |json|
      if json['name'] =~ REGEX_NAME
        record.errors[attribute] << (options[:message] || "element #{json} with invalid name")
      end
    end
  end

  def validate_identifier(record, attribute, value)
    value.each do |json|
      if json['identifier'] =~ REGEX_IDENTIFIER
        record.errors[attribute] << (options[:message] || "element #{json} with invalid identifier")
      end
    end
  end
end