class Profile::SubscriptionsController < Profile::BaseController
  inherit_resources
  respond_to :html, :csv

  def index
    index! do |format|
      format.html { render :index }
      format.csv  do
        mixpanel_tracker.track_event :export_subscribers_list
        send_data users.to_csv
      end
    end
  end

  private

  def end_of_association_chain
    super.subscribed
  end

  def users
    User.where(id: collection.pluck(:user_id))
  end

  def begin_of_association_chain
    current_profile
  end
end
