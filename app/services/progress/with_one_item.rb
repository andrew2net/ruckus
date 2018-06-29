class Progress::WithOneItem < Progress::Base
  def total_items_count
    1
  end

  def percent_per_item
    5
  end

  def completed_items_count
    completed? ? 1 : 0
  end

  private

  def any_of_profile_fields_present?(*fields)
    fields.any? { |field| @profile.attributes[field.to_s].present? }
  end
end
