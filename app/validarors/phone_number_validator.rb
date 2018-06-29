class PhoneNumberValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value.present?
      validate_format(record, attribute, value)
      validate_start_and_end(record, attribute, value)
      validate_multi_hyphen(record, attribute, value)
    end
  end

  def validate_format(record, attribute, value)
    if value !~ /\A[\d-]*\z/
      record.errors[attribute] << "Allowed only digit and hyphen '-'"
    end
  end

  def validate_start_and_end(record, attribute, value)
    if value.start_with?('-') || value.end_with?('-')
      record.errors[attribute] << "Phone can't start or end with '-'"
    end
  end

  def validate_multi_hyphen(record, attribute, value)
    if value.include?('--')
      record.errors[attribute] << "Please remove extra dash."
    end
  end
end
