class Progress::ContactInfo < Progress::WithOneItem
  def completed?
    any_of_profile_fields_present?(:address_1, :address_2, :phone, :contact_city, :contact_state,
                                   :campaign_website)
  end
end
