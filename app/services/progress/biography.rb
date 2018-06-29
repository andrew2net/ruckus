class Progress::Biography < Progress::WithOneItem
  def completed?
    @profile.biography.present?
  end
end
