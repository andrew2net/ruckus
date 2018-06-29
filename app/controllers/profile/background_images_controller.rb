class Profile::BackgroundImagesController < Profile::BaseController
  layout 'account/admin/modal'
  before_action :load_media, only: [:edit, :update]

  def edit
    current_profile.build_background_image_medium if current_profile.background_image_medium.blank?
  end

  def update
    if updater.process
      mixpanel_tracker.add_event :background_image_update
      mixpanel_tracker.track
    end
  end

  private

  def load_media
    allowed = current_profile.allowed_background_images
    @profile_media = allowed.with_profile
    @ruckus_media = allowed.ruckus_global
  end

  def permitted_params
    params.permit(profile: [:background_image_medium_id, :background_image_cropping_width,
                            :background_image_cropping_height, :background_image_cropping_offset_x,
                            :background_image_cropping_offset_y, background_image_medium: [:image]])
  end

  def updater
    @updater ||= Media::ProfileUpdater::BackgroundImage.new(current_profile, permitted_params)
  end
end
