class ZipFormatValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value.present? && !validate_zip_format(record, attribute, value)
      record.errors[attribute] << 'is not valid ZIP'
    end
  end

  private

  def validate_zip_format(record, attribute, value)
    value =~ /^\d{5}(?:[-]\d{4})?$/
  end
end

