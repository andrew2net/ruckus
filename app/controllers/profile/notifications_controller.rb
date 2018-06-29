class Profile::NotificationsController < Profile::BaseController
  inherit_resources
  include ProfileableController

  def update
    update! { edit_profile_notification_path }
  end

  private

  def permitted_params
    params.permit(profile: [:donation_notifications_on, :weekly_report_on, :signup_notifications_on])
  end
end
