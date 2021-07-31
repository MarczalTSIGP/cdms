class JsonValidator < ActiveModel::EachValidator
    REGEX_NAME = /[{}@!#%^&*()$]/
    REGEX_IDENTIFIER = /[{}@!#%^&*_()$\s\[\]]/
    
    def validate_each(record, attribute, value)
        unless value.is_a?(Array)
            record.errors.add attribute, (options[:message] || "is not an Array")
        end  
        if value.is_a?(Array)
            value.each do |json|
                unless json.has_key?('name') && json.has_key?('identifier')
                    record.errors.add attribute, (options[:message] || "element #{json} with invalid format")
                end
                if json['name'] =~ REGEX_NAME
                    record.errors[attribute] << (options[:message] || "element #{json} with invalid name")
                end
                if json['identifier'] =~ REGEX_IDENTIFIER
                    record.errors[attribute] << (options[:message] || "element #{json} with invalid identifier")
                end
            end
        end
    end
end
