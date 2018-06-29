class Progress::Base
  def initialize(profile)
    @profile = profile
  end

  def completed_percent
    completed_items_count * percent_per_item
  end
end
