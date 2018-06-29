class Media::ProfileUpdater::Photo < Media::ProfileUpdater::Base
  private

  def find_medium
    @profile.media.find_by(id: @params[:photo_medium_id])
  end

  def create_medium
    @profile.media.create(image: @params[:photo_medium][:image])
  end

  def updating_params
    {
      photo_cropping_width:    @params[:photo_cropping_width],
      photo_cropping_offset_x: @params[:photo_cropping_offset_x],
      photo_cropping_offset_y: @params[:photo_cropping_offset_y],
      photo_medium_id:         medium.id,
      photo:                   medium.image.file,
    }
  end
end
