class Progress::BackgroundImage < Progress::WithOneItem
  def completed?
    @profile.background_image_medium.present? && @profile.background_image.present?
  end
end
