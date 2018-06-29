class Admin::ProfilesController < Admin::BaseController
  inherit_resources
  belongs_to :account

  def destroy
    destroy! { admin_accounts_path }
  end

  private
  def permitted_params
    attributes = [:first_name, :last_name, :name, :office, :tagline, :city, :state, :party_affiliation,
                  :biography, :donation_notifications_on, :weekly_report_on, :donations_on, :phone,
                  :events_on, :endorsements_on, :questions_on, :social_feed_on, :address_1, :address_2,
                  :campaign_website, :campaign_organization, :contact_city, :contact_state, :issues_on,
                  :media_on, :biography_on, :signup_notifications_on, :premium_by_default, :media_stream_ids,
                  :district, :contact_zip, :campaign_organization_identifier]

    params.permit(profile: attributes,
                  candidate_profile: attributes,
                  organization_profile: attributes)
  end
end
