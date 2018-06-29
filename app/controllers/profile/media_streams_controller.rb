class Profile::MediaStreamsController < Profile::BaseController
  layout 'account/admin/modal'

  def create
    Media::Creator.new(current_profile, permitted_params[:media_items]).create
    render :show
  end

  def update
    update_positions
    render :show
  end

  def sort
    update_positions
  end

  private

  def permitted_params
    params.permit(profile: [media_stream_ids: []], media_items: [:video_url, images: []])
  end

  def update_positions
    current_profile.media.update_all(position: nil)

    if permitted_params.try(:[], :profile).try(:[], :media_stream_ids).present?
      Medium.update_positions(params[:profile][:media_stream_ids], profile_id: current_profile.id)
      mixpanel_tracker.track_event :media_stream_update
      mixpanel_tracker
    end
  end
end
