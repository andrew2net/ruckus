class Profile::DeAccountsController < Profile::BaseController
  inherit_resources
  defaults singleton: true

  def new
    @de_account = current_profile.build_de_account
    @de_account.email = current_account.email
    @de_account.contact_email = current_account.email
    @de_account.account_full_name = current_profile.name
    @de_account.account_party = current_profile.party_affiliation

    @de_account.account_address = current_profile.address_1
    @de_account.account_city = current_profile.contact_city
    @de_account.account_state = current_profile.contact_state
    @de_account.account_zip = current_profile.contact_zip
    @de_account.account_district_or_locality = current_profile.district

    @de_account.account_committee_name = current_profile.campaign_organization
    @de_account.account_committee_id = current_profile.campaign_organization_identifier
    @de_account.account_campaign_disclaimer = current_profile.campaign_disclaimer

    @de_account.billing_name = current_profile.name
    @de_account.billing_address = current_profile.address_1
    @de_account.billing_city = current_profile.contact_city
    @de_account.billing_state = current_profile.contact_state
    @de_account.billing_zipcode = current_profile.contact_zip

    @de_account.contact_first_name = current_profile.first_name
    @de_account.contact_last_name = current_profile.last_name
    @de_account.contact_email = current_account.email
    @de_account.contact_phone = current_profile.phone
    @de_account.contact_address = current_profile.address_1
    @de_account.contact_city = current_profile.contact_city
    @de_account.contact_state = current_profile.contact_state
    @de_account.contact_zip = current_profile.contact_zip

    @credit_card = @de_account.build_credit_card

    mixpanel_tracker.track_event :enable_donation_start
  end

  def create
    @de_account = current_profile.build_de_account permitted_params[:de_account]
    if @de_account.save
      mixpanel_tracker.track_event :enable_donation_finish
      flash[:notice] = 'Payment account was successfully created.'
      redirect_to edit_profile_page_option_path
    else
      mixpanel_tracker.track_event :enable_donation_error
      render :new
    end
  end

  def show
    raise ActionController::RoutingError.new('Not Found') if resource.nil?
  end

  def destroy
    resource.destroy
    redirect_to edit_profile_page_option_path
  end

  private

  def permitted_params
    params.permit(de_account: [
      :id, :email, :account_full_name, :account_committee_name, :account_committee_id, :account_address, :account_city,
      :account_state, :account_zip, :account_recipient_kind, :account_district_or_locality,
      :account_campaign_disclaimer, :contribution_limit, :show_employer_name, :show_employer_address, :show_occupation,
      :bank_account_name, :bank_routing_number, :bank_account_number, :bank_account_number_confirmation,
      :contact_last_name, :contact_email, :contact_phone, :uuid, :created_at, :updated_at, :contact_first_name,
      :contact_address, :contact_city, :contact_state, :contact_zip, :account_party, :agreements, :password,
      :password_confirmation, :billing_name, :billing_address, :billing_city, :billing_state, :billing_zipcode,
      credit_card_attributes: [:number, :cvv, :month, :year], agreements: []
    ])
  end

  def begin_of_association_chain
    current_profile
  end
end
