class Progress::MediaStream < Progress::WithManyItems
  def total_items_count
    5
  end

  def percent_per_item
    4
  end

  private

  def all_completed_items_count
    @profile.media_stream_items.count
  end
end
