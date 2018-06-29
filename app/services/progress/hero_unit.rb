class Progress::HeroUnit < Progress::WithOneItem
  def completed?
    @profile.hero_unit_medium.present? && @profile.hero_unit.present?
  end
end
