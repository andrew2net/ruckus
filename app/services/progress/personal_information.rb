class Progress::PersonalInformation < Progress::WithOneItem
  def completed?
    any_of_profile_fields_present?(:city, :state, :party_affiliation, :district, :office)
  end
end
