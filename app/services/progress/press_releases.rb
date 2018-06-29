class Progress::PressReleases < Progress::WithManyItems
  def total_items_count
    2
  end

  def percent_per_item
    5
  end

  private

  def all_completed_items_count
    @profile.press_releases.count
  end
end
