class Percent::Cell < Cell::ViewModel
  include Cacheable

  self_contained!

  def show
    render
  end

  def progresses
    @progresses ||= {
      social_account:       Progress::SocialAccount.new(profile),
      donations:            Progress::Donations.new(profile),
      biography:            Progress::Biography.new(profile),
      photo:                Progress::Photo.new(profile),
      issues:               Progress::Issues.new(profile),
      campaign_update:      Progress::CampaignUpdate.new(profile),
      background_image:     Progress::BackgroundImage.new(profile),
      hero_unit:            Progress::HeroUnit.new(profile),
      media_stream:         Progress::MediaStream.new(profile),
      events:               Progress::Events.new(profile),
      press_releases:       Progress::PressReleases.new(profile),
      contact_info:         Progress::ContactInfo.new(profile),
      personal_information: Progress::PersonalInformation.new(profile)
    }
  end

  def percent_completed
    progresses.sum { |_, progress| progress.completed_percent }
  end

  def item_link_to(caption, path, progress)
    render partial: 'item', locals: { caption: caption, path: path, progress: progress }
  end

  def labels
    @labels ||= LabelsDictionary.new(profile)
  end

  private

  def any_of_profile_fields_present?(*fields)
    fields.any? { |field| profile.attributes[field.to_s].present? }
  end

  def profile
    model.profile
  end
end
