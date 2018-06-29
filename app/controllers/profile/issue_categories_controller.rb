class Profile::IssueCategoriesController < Profile::BaseController
  respond_to :js

  def create
    @issue_category = current_profile.issue_categories.new permitted_params[:issue_category]
    if @issue_category.save
      mixpanel_tracker.track_event :add_new_issue_topic if current_profile.candidate?
      mixpanel_tracker.track_event :add_new_position_topic if current_profile.organization?
    else
      flash.now[:alert] = @issue_category.errors.full_messages.join(', ')
    end
  end

  private

  def permitted_params
    params.permit(issue_category: [:name])
  end
end
