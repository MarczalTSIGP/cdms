class JsonValidator < ActiveModel::EachValidator
  REGEX_NAME = /[{}@!#%^&*()$]/.freeze
  REGEX_IDENTIFIER = /[{}@!#%^&*_()$\s]/.freeze

  def validate_each(record, attribute, value)
    @record = record
    @attribute = attribute
    @value = value
    validate_is_array
    validate_json_keys
  end

  def validate_is_array
    @record.errors.add @attribute, I18n.t('activerecord.errors.messages.not_an_array') unless @value.is_a?(Array)
  end

  def validate_json_keys
    return unless @value.is_a?(Array)

    @value.each do |json|
      unless json.key?('name') && json.key?('identifier')
        @record.errors.add @attribute, I18n.t('activerecord.errors.messages.invalid')
      end
    end
  end
end
