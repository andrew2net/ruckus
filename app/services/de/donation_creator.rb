class De::DonationCreator
  require 'deapi'
  attr_accessor :profile, :recipient_id, :submitted_info, :formatted_data

  def process(submitted_info)
    @formatted_data = format_data(submitted_info)
    DEApi.create_donation(@formatted_data)
  end

  def format_data(submitted_info)
    @profile = Profile.find(submitted_info[:profile_id])

    # Set to '1' if you want to create donations in localhost browser
    # '1' is Recipient ID of activated recipient on DemocracyEngine.
    @recipient_id = @profile.de_account.uuid
    @recipient_id = '1' if Rails.env.development?

    @submitted_info = submitted_info.with_indifferent_access

    {
      donor_first_name:            @submitted_info[:donor_first_name],
      donor_last_name:             @submitted_info[:donor_last_name],
      donor_address1:              @submitted_info[:donor_address_1],
      donor_address2:              @submitted_info[:donor_address_2],
      donor_city:                  @submitted_info[:donor_city],
      donor_state:                 @submitted_info[:donor_state],
      donor_zip:                   @submitted_info[:donor_zip],
      donor_email:                 @submitted_info[:donor_email],
      donor_phone:                 @submitted_info[:donor_phone],
      cc_number:                   @submitted_info[:cc_number],
      cc_verification_value:       @submitted_info[:cc_cvv],
      cc_month:                    @submitted_info[:cc_month],
      cc_year:                     @submitted_info[:cc_year],
      cc_first_name:               @submitted_info[:donor_first_name],
      cc_last_name:                @submitted_info[:donor_last_name],
      cc_zip:                      @submitted_info[:donor_zip],
      fee_tier:                    @submitted_info[:fee_tier],
      compliance_employer:         @submitted_info[:employer_name],
      compliance_occupation:       @submitted_info[:employer_occupation],
      compliance_employer_address: @submitted_info[:employer_address],
      compliance_employer_city:    @submitted_info[:employer_city],
      compliance_employer_state:   @submitted_info[:employer_state],
      compliance_employer_zip:     @submitted_info[:employer_zip],
      line_items:                  [{ amount:      "$#{@submitted_info[:amount]}",
                                      recipient_id: @recipient_id }]
    }
  end
end
