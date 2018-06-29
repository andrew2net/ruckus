class TimeCorrectnessValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value.present? && !validate_time_correctness(record, attribute, value)
      record.errors[attribute] << 'invalid value'
    end
  end

  private
  def validate_time_correctness(record, attribute, value)
    Time.parse(value)
  rescue ArgumentError
    false
  end
end
