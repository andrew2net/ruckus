class Profile::GeneralInfosController < Profile::BaseController
  inherit_resources
  include ProfileableController
  include ModalController

  def update
    display_changes if resource.update permitted_params[:profile]
  end

  private

  def permitted_params
    fields = [:name, :office, :city, :state, :tagline, :party_affiliation, :district, :address_1, :address_2,
              :phone, :contact_city, :contact_zip, :contact_state, :campaign_website, :campaign_disclaimer]
    fields << :register_to_vote_url if ruckus?
    params.permit(profile: fields)
  end

  def display_changes
    mixpanel_tracker.track
    render 'show'
  end
end
