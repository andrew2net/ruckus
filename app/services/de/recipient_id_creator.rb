class De::RecipientIdCreator
  require 'deapi'
  attr_accessor :submitted_attrubutes, :formatted_data

  def initialize(attributes)
    @submitted_attrubutes = attributes
    @formatted_data = format_data.with_indifferent_access
  end

  def process
    submit_data_to_de
  end

  private
  def submit_data_to_de
    DEApi.create_recipient(@formatted_data)
  end

  def format_data
    {
      name: @submitted_attrubutes[:account_full_name],
      remote_recipient_id: @submitted_attrubutes[:uuid],
      registered_id:  @submitted_attrubutes[:account_committee_id],
      recipient_type: @submitted_attrubutes[:account_recipient_kind],
      contact: {  # recipient info
        first_name: @submitted_attrubutes[:contact_first_name],
        last_name:  @submitted_attrubutes[:contact_last_name],
        phone:      @submitted_attrubutes[:contact_phone],
        address1:   @submitted_attrubutes[:contact_address],
        city:       @submitted_attrubutes[:contact_city],
        state:      @submitted_attrubutes[:contact_state],
        zip:        @submitted_attrubutes[:contact_zip],
        bank_name:            @submitted_attrubutes[:bank_account_name], #?
        bank_routing_number:  @submitted_attrubutes[:bank_routing_number],
        bank_account_number:  @submitted_attrubutes[:bank_account_number],
      },
      user: {  # person who can read reports
        first_name:       @submitted_attrubutes[:contact_first_name],
        last_name:        @submitted_attrubutes[:contact_last_name],
        login:            @submitted_attrubutes[:email],
        initial_password: @submitted_attrubutes[:password],
        email:            @submitted_attrubutes[:email]
      },
      recipient_tags: {
        party: @submitted_attrubutes[:account_party],
        state: @submitted_attrubutes[:account_state],
        locality: @submitted_attrubutes[:account_district_or_locality],
      }
    }
  end
end
