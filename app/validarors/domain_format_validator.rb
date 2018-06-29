class DomainFormatValidator < ActiveModel::EachValidator
  RESERVED_NAMES = %w(www ftp mail pop smtp ssl sftp http https)

  def validate_each(record, attribute, value)
    if value.present?
      validate_format(record, attribute, value)
      validate_first_and_last_symbols(record, attribute, value)
      validate_length(record, attribute, value)
      validate_reserved(record, attribute, value)
      validate_staging(record, attribute, value)
    end
  end

  private

  def validate_reserved(record, attribute, value)
    if RESERVED_NAMES.any? { |reserved_name| value.start_with?("#{reserved_name}.") }
      record.errors[attribute] << 'cannot be a reserved name'
    end
  end

  def validate_staging(record, attribute, value)
    record.errors[attribute] << 'cannot be set to "ruck.us"' if value == 'ruck.us'
    record.errors[attribute] << 'cannot be set to "devruck.us"' if value == 'devruck.us'
    record.errors[attribute] << 'cannot be a subdomain of "ruck.us"' if value =~ /.*\.ruck\.us/
    record.errors[attribute] << 'cannot be a subdomain of "devruck.us"' if value =~ /.*\.devruck\.us/
  end

  def validate_format(record, attribute, value)
    reg = /\A[a-z0-9\-\.]*$/ix

    if (value =~ reg).nil?
      record.errors[attribute] << 'invalid domain name'
    end
  end

  def validate_first_and_last_symbols(record, attribute, value)
    start  = /\A[\-\.]/ix
    finish = /[\-\.]$/ix

    if (value =~ start).present? || (value=~ finish).present?
      record.errors[attribute] << 'can not start or end with special symbols'
    end
  end

  def validate_length(record, attribute, value)
    unless value.length.between?(1, 63)
      record.errors[attribute] << 'should be between 1 and 63 letters long'
    end
  end
end
