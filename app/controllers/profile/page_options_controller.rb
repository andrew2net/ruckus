class Profile::PageOptionsController < Profile::BaseController
  layout 'account/admin/main'
  before_action :add_mixpanel_events, only: :update

  def update
    mixpanel_tracker.track if current_profile.update(permitted_params[:profile])
    redirect_to edit_profile_page_option_path
  end

  private

  def permitted_params
    params.permit(profile: profile_options)
  end

  def add_mixpanel_events
    display_settings = profile_options - [:donations_on]
    if display_settings.any? { |attr| profile_value_changed?(attr, permitted_params[:profile]) }
      mixpanel_tracker.add_event(:display_settings_update)
    end

    if profile_value_changed?(:donations_on, permitted_params[:profile])
      event = current_profile.donations_on ? :disable_donation_success : :enable_donation_success
      mixpanel_tracker.add_event(event)
    end
  end

  def profile_options
    [:donations_on, :events_on, :questions_on, :press_on, :social_feed_on, :issues_on, :biography_on,
     :media_on, :register_to_vote_on]
  end
end
