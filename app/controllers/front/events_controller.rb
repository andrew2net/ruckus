class Front::EventsController < Front::BaseAccountController
  include FacebookController
  layout false
  inherit_resources
  belongs_to :profile
  respond_to :html, :js

  def index
    index! do |format|
      format.html { render 'index', layout: false }
    end
  end

  def collection
    @events = parent.events
    if params[:event_id].present?
      @event = @events.find(params[:event_id])
      @events = @events.same_month(@event).earliest_first
    end


    @events = @events.archive if params[:archive].present?
  end
end
