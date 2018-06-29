module ProfileableController
  extend ActiveSupport::Concern

  included do
    defaults instance_name: :profile
    before_action :add_mixpanel_events, only: :update
  end

  def update
    update! { edit_resource_path }
  end

  private
  def add_mixpanel_events
    mixpanel_tracker.add_event :display_name_update if value_changed?(:name) && current_profile.candidate?
    mixpanel_tracker.add_event :org_display_name_update if value_changed?(:name) && current_profile.organization?
    mixpanel_tracker.add_event :tagline_update if value_changed?(:tagline) && current_profile.candidate?
    mixpanel_tracker.add_event :org_tagline_update if value_changed?(:tagline) && current_profile.organization?
    mixpanel_tracker.add_event :party_update if value_changed?(:party_affiliation)
    mixpanel_tracker.add_event :display_city_update if value_changed?(:city)
    mixpanel_tracker.add_event :display_state_update if value_changed?(:state)
    mixpanel_tracker.add_event :constituency_update if value_changed?(:district)
    mixpanel_tracker.add_event :display_address1_update if value_changed?(:address_1)
    mixpanel_tracker.add_event :display_address2_update if value_changed?(:address_2)
    mixpanel_tracker.add_event :display_url_update if value_changed?(:campaign_website)
    mixpanel_tracker.add_event :disclaimer_update if value_changed?(:campaign_disclaimer)
    mixpanel_tracker.add_event :display_phone_update if value_changed?(:phone)
    mixpanel_tracker.add_event :office_update if value_changed?(:office)

    mixpanel_tracker.track_event :edit_facebook if value_changed?(:facebook_on)
    mixpanel_tracker.track_event :edit_twitter if value_changed?(:twitter_on)

    mixpanel_tracker.track_event :notifications_settings_update if values_changed?(notification_switches)

    mixpanel_tracker.track_event :display_settings_update if values_changed?(display_switches)
    mixpanel_tracker.track_event :enable_donation_success if value_changed?(:donations_on) && !current_profile.donations_on
    mixpanel_tracker.track_event :disable_donation_success if value_changed?(:donations_on) && current_profile.donations_on
  end

  def resource
    params[:id].present? ? current_account.profiles.find(params[:id]) : current_account.profile
  end

  def value_changed?(attr)
    params[:profile].present? && !params[:profile][attr].nil? && resource[attr] != params[:profile][attr]
  end

  def values_changed?(attrs)
    attrs.select{ |attr| value_changed?(attr) }.any?
  end

  def notification_switches
    [:donation_notifications_on, :weekly_report_on, :signup_notifications_on]
  end

  def display_switches
    [:events_on, :press_on, :questions_on, :social_feed_on, :issues_on,
     :media_on, :biography_on, :hero_unit_on]
  end
end
