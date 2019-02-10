class Front::UsersController < Front::BaseAccountController
  inherit_resources
  belongs_to :profile
  respond_to :js
  # after_action :send_subscribe_message, only: [:create]

  def create
    if params[:user][:name].blank?
      @user = User.subscribe(params[:user][:email], parent)
      @profile = ProfileDecorator.decorate(parent)
      mixpanel_tracker ||= mixpanel_tracker(parent.account)
      mixpanel_tracker.track_event :visitor_subscribe, subscriber_name: resource.name, subscriber_email: resource.email, subscribe_date: Date.today
      send_subscribe_message
    else
      @user = User.new
    end
  end

  private

  def send_subscribe_message
    AccountMailer.subscribe_message(resource.id, parent.account.id).deliver if resource.errors.empty?
  end
end
