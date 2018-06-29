class Profile::PhotosController < Profile::BaseController
  layout 'account/admin/modal'
  before_action :load_media, only: [:edit, :update]

  def edit
    current_profile.build_photo_medium if current_profile.photo_medium.blank?
  end

  def update
    if updater.process
      mixpanel_tracker.add_event :profile_image_update if current_profile.candidate?
      mixpanel_tracker.add_event :logo_image_update if current_profile.organization?
      mixpanel_tracker.track
    end
  end

  private

  def load_media
    @media = current_profile.media.only_images
  end

  def permitted_params
    params.permit(profile: [:photo_medium_id, :photo_cropping_width, :photo_cropping_offset_x,
                            :photo_cropping_offset_y, photo_medium: [:image]])
  end

  def updater
    @updater ||= Media::ProfileUpdater::Photo.new(current_profile, permitted_params)
  end
end
