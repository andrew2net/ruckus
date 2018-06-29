class Profile::DashboardsController < Profile::BaseController
  inherit_resources
  include ProfileableController

  before_action :get_data

  private
  def get_data
    @social_post = current_profile.social_posts.build
    @social_posts = current_profile.social_posts.order(created_at: :desc)
    @donations_raised = current_profile.sum_donations
    @subscriptions_count = current_profile.subscriptions.subscribed.count
    @events_by_month = current_profile.events.upcoming.earliest_first.group_by{ |event| event.start_time.beginning_of_month }
    @users_count = current_profile.subscriptions.subscribed.count
  end
end
