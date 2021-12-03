class JsonValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    @record = record
    @attribute = attribute
    @value = value

    @schema = options[:schema]

    validate_type
    validate_properties
    validate_uniqueness
  end

  def validate_type
    type = @schema[:type]
    return true unless type

    @record.errors.add @attribute, I18n.t('activerecord.errors.messages.not_an', type: type) unless @value.is_a?(type)
  end

  def validate_properties
    return unless @record.errors.empty?

    properties = @schema[:properties]
    return unless properties

    case @value
    when Array
      @value.each { |json| same_keys?(properties, json) }
    when Hash
      same_keys?(@value)
    end
  end

  private

  def same_keys?(expected, actual)
    expected_keys = expected.keys.map(&:to_s)
    actual_keys = actual.keys.map(&:to_s)

    has_same_keys = expected_keys.difference(actual_keys).empty? && actual_keys.difference(expected_keys).empty?
    @record.errors.add @attribute, I18n.t('activerecord.errors.messages.invalid') unless has_same_keys
  end

  def validate_uniqueness
    return unless @value.is_a?(Array)

    properties = @schema[:properties]

    keys_uniquess = properties.select { |_key, value| value[:unique] }.keys
    validate_uniqueness_of_keys(keys_uniquess)
  end

  def validate_uniqueness_of_keys(keys)
    keys.each do |key|
      r = @value.group_by { |json| json[key.to_s] }.select { |_key, value| value.size > 1 }

      @record.errors.add @attribute, I18n.t('activerecord.errors.messages.taken', key: key) unless r.empty?
    end
  end
end
