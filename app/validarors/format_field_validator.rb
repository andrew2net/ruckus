class FormatFieldValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value =~ /^([a-z]|[A-Z])/
      record.errors[attribute] << (options[:message] || 'should not contain any special characters')
    end
  end
end
