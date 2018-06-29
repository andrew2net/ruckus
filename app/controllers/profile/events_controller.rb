class Profile::EventsController < Profile::BaseController
  inherit_resources
  layout 'account/admin/modal'
  before_action :set_date
  before_action :set_current_month_events
  respond_to :html, :js

  def create
    create! do |success, failure|
      success.js do
        mixpanel_tracker.track_event :add_new_event
        render :show
      end
    end
  end

  def update
    update! do |success, failure|
      success.js do
        mixpanel_tracker.track_event :event_update
        render :show
      end
    end
  end

private
  def collection; end

  def event_params
    params.require(:event).permit(:title, :link_text, :link_url, :start_time_date, :start_time_time, :end_time_date,
                                  :end_time_time, :address, :city, :time_zone, :state, :zip, :description)
  end

  def set_date
    @date = params[:month].present? ? Date.parse("#{params[:month]}-01") : Date.today
  rescue ArgumentError
    Date.today
  end

  def set_current_month_events
    @current_month_events = current_profile.events.earliest_first.by_month(@date.month)
  end

  def begin_of_association_chain
    current_profile
  end
end
