class Profile::PressReleasesController < Profile::BaseController
  inherit_resources
  layout 'account/admin/modal'
  respond_to :html, :js

  def create
    attrs = permitted_params[:press_release].merge(build_from_url: true)
    @press_release = current_profile.press_releases.new(attrs)

    create! do |success, failure|
      success.js do
        mixpanel_tracker.track_event :add_new_press
        render :show
      end
    end
  end

  def update
    update! do |success, failure|
      success.js do
        mixpanel_tracker.track_event :press_update
        render :show
      end
    end
  end

  def sort
    PressRelease.update_positions(params[:ids])
  end

  private

  def collection
    @press_releases ||= end_of_association_chain.by_position
  end

  def permitted_params
    params.permit(press_release: [:id, :title, :url, :page_title, :page_date, :page_title_enabled,
                                  :page_date_enabled, :active_image_id, :page_thumbnail_enabled])
  end

  def begin_of_association_chain
    current_profile
  end
end
