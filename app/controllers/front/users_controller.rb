class Front::UsersController < Front::BaseAccountController
  inherit_resources
  belongs_to :profile
  respond_to :js
  after_action :send_subscribe_message, only: [:create]

  def create
    @user = User.subscribe(params[:user][:email], parent)
    @profile = ProfileDecorator.decorate(parent)
    mixpanel_tracker ||= mixpanel_tracker(parent.account)
    mixpanel_tracker.track_event :visitor_subscribe, subscriber_name: resource.name, subscriber_email: resource.email, subscribe_date: Date.today
  end

  private

  def send_subscribe_message
    AccountMailer.subscribe_message(resource, parent.account).deliver if resource.errors.empty?
  end
end
