class Progress::WithManyItems < Progress::Base
  def completed_items_count
    @all_completed_items_count ||= all_completed_items_count
    @all_completed_items_count > total_items_count ? total_items_count : @all_completed_items_count
  end

  def completed?
    completed_items_count == total_items_count
  end
end
