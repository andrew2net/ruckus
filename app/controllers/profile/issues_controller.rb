class Profile::IssuesController < Profile::BaseController
  inherit_resources
  layout 'account/admin/modal'
  respond_to :js

  def create
    create! do |success, failure|
      success.js do
        mixpanel_tracker.track_event(:add_new_issue, issue_name: resource.title) if current_profile.candidate?
        mixpanel_tracker.track_event(:add_new_position, position_name: resource.title) if current_profile.organization?
        render :show
      end

      failure.js { render :create }
    end
  end

  def update
    update! do |success, failure|
      success.js do
        mixpanel_tracker.track_event(:issue_update, issue_name: resource.title) if current_profile.candidate?
        mixpanel_tracker.track_event(:position_update, position_name: resource.title) if current_profile.organization?
        render :show
      end

      failure.js { render :update }
    end
  end

  def sort
    Issue.update_positions(params[:ids], profile_id: current_profile.id)
  end

  private

  def begin_of_association_chain
    @begin_of_association_chain ||= current_profile
  end

  def end_of_association_chain
    @end_of_association_chain ||= super.by_position
  end

  def permitted_params
    params.permit(issue: [:title, :description, :issue_category_id])
  end
end
