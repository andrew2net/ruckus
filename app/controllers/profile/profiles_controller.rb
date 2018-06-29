class Profile::ProfilesController < Profile::BaseController
  inherit_resources
  include ProfileableController

  def update
    update! do |format|
      format.js { render :update }
    end
  end

  private

  def permitted_params
    params.permit(profile: [:biography_on, :events_on, :press_on,
                            :hero_unit_on, :issues_on, :media_on,
                            :donations_on, :questions_on, :theme,
                            :active])
  end
end
