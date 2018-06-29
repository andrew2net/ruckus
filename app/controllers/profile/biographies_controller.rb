class Profile::BiographiesController < Profile::BaseController
  layout 'account/admin/modal'
  before_action :add_mixpanel_events, only: :update

  def update
    if current_profile.update(permitted_params[:profile])
      mixpanel_tracker.track
      render 'show'
    end
  end

  private

  def permitted_params
    params.permit(profile: [:biography])
  end

  def add_mixpanel_events
    if profile_value_changed?(:biography, permitted_params[:profile])
      mixpanel_tracker.add_event(current_profile.candidate? ? :biography_update : :org_bio_update)
    end
  end
end
