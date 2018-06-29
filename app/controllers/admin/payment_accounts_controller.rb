class Admin::PaymentAccountsController < Admin::BaseController
  inherit_resources
  defaults resource_class: DeAccount, collection_name: :payment_accounts, instance_name: :payment_account

  private

  def permitted_params
    params.permit(de_account: [
      :email, :account_full_name, :account_committee_name, :account_address, :account_city, :account_state,
      :account_zip, :account_recipient_kind, :account_district_or_locality, :account_campaign_disclaimer,
      :contribution_limit, :show_employer_name, :show_employer_address, :show_occupation, :bank_account_name,
      :bank_routing_number, :bank_account_number, :bank_account_number_confirmation, :contact_last_name, :contact_email,
      :contact_phone, :uuid, :contact_first_name, :contact_address, :contact_city, :contact_state, :contact_zip,
      :account_party, :agreements, :password, :password_confirmation, :billing_name, :billing_address, :billing_city,
      :billing_state, :billing_zipcode, agreements: []
    ])
  end
end
