class Progress::SocialAccount < Progress::WithOneItem
  include Cacheable

  def completed?
    cached_method(:completed?) { @profile.oauth_accounts.active.exists? }
  end
end
