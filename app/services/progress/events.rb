class Progress::Events < Progress::WithManyItems
  def total_items_count
    2
  end

  def percent_per_item
    5
  end

  private

  def all_completed_items_count
    @profile.events.count
  end
end
