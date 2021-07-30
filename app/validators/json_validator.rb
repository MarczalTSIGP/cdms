class JsonValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
        unless value.is_a?(Array)
            record.errors.add attribute, (options[:message] || "is not an Array")
        end
        if value.is_a?(Array)
            value.each do |json|
                unless json.has_key?('name') && json.has_key?('identifier')
                    record.errors.add attribute, (options[:message] || "element #{json} with invalid format")
                end
            end
        end
    end
end