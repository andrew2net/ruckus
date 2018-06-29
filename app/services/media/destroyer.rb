class Media::Destroyer
  def initialize(medium)
    @medium = medium
  end

  def process
    remove_photo_copies
    remove_background_image_copies
    remove_hero_unit_copies
    @medium.destroy
  end

  private

  def remove_photo_copies
    Profile.where(photo_medium_id: @medium.id).update_all(
      photo_medium_id:         nil,
      photo_cropping_width:    nil,
      photo_cropping_offset_x: nil,
      photo_cropping_offset_y: nil,
      photo:                   nil
    )
  end

  def remove_background_image_copies
    Profile.where(background_image_medium_id: @medium.id).update_all(
      background_image_medium_id:         nil,
      background_image_cropping_width:    nil,
      background_image_cropping_height:   nil,
      background_image_cropping_offset_y: nil,
      background_image_cropping_offset_x: nil,
      background_image:                   nil
    )
  end

  def remove_hero_unit_copies
    Profile.where(hero_unit_medium_id: @medium.id).update_all(hero_unit_medium_id: nil, hero_unit: nil)
  end
end
