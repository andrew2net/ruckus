class Profile::SubdomainsController < Profile::BaseController
  inherit_resources
  defaults singleton: true

  respond_to :js, only: [:edit, :update, :show]

  def update
    if resource.update permitted_params[:domain]
      mixpanel_tracker.track_event :ruckus_url_update
      render :show
    else
      render :edit
    end
  end

  private

  def resource
    @subdomain ||= current_profile.domains.internal.first
  end

  def permitted_params
    params.permit(domain: [:name])
  end
end
