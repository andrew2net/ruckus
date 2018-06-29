class Media::ProfileUpdater::BackgroundImage < Media::ProfileUpdater::Base
  private

  def find_medium
    @profile.allowed_background_images.find_by(id: @params[:background_image_medium_id])
  end

  def create_medium
    @profile.media.create(image: @params[:background_image_medium][:image])
  end

  def updating_params
    {
      background_image_cropping_width:    @params[:background_image_cropping_width],
      background_image_cropping_height:   @params[:background_image_cropping_height],
      background_image_cropping_offset_x: @params[:background_image_cropping_offset_x],
      background_image_cropping_offset_y: @params[:background_image_cropping_offset_y],
      background_image_medium_id:         medium.id,
      background_image:                   medium.image.file,
    }
  end
end
