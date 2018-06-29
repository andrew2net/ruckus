class Progress::Photo < Progress::WithOneItem
  def completed?
    @profile.photo_medium.present? && @profile.photo.present?
  end
end
