class Progress::CampaignUpdate < Progress::WithOneItem
  include Cacheable

  def completed?
    cached_method(:completed?) { @profile.social_posts.exists? }
  end
end
