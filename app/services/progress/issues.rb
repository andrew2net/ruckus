class Progress::Issues < Progress::WithManyItems
  def total_items_count
    3
  end

  def percent_per_item
    5
  end

  private

  def all_completed_items_count
    @profile.issues.count
  end
end
