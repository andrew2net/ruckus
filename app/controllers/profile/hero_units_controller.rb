class Profile::HeroUnitsController < Profile::BaseController
  layout 'account/admin/modal'
  before_action :load_media, only: [:edit, :update]

  def edit
    current_profile.build_hero_unit_medium if current_profile.hero_unit_medium.blank?
  end

  def update
    if updater.process
      mixpanel_tracker.add_event :featured_media_update
      mixpanel_tracker.track
    end
  end

  private

  def load_media
    @media = current_profile.media.by_position
  end

  def permitted_params
    params.permit(profile: [:hero_unit_medium_id, hero_unit_medium: [:image, :video_url]])
  end

  def updater
    @updater ||= Media::ProfileUpdater::HeroUnit.new(current_profile, permitted_params)
  end
end
