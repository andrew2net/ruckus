class AmountInclusionValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value.present? && !validate_amount_inclusion(record, attribute, value)
      record.errors[attribute] << 'is not allowed amount'
    end
  end

  private

  def validate_amount_inclusion(record, attribute, value)
    record.profile.de_account.donation_amounts.include? value
  end
end

