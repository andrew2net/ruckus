class SocialPost < ActiveRecord::Base
  belongs_to :profile
  has_many :scores, as: :scorable
  has_many :oauth_accounts, through: :profile

  validates :message, presence: true
  validate :provider_inclusion
  validate :message_length

  after_validation :submit_to_facebook, if: :should_post_to_facebook?
  after_validation :submit_to_twitter, if: :should_post_to_twitter?

  serialize :provider, Array

  def has_social_errors?
    social_errors.any?
  end

  def social_errors
    OauthAccount::PROVIDERS.map { |provider_name| errors[provider_name.to_sym] }.flatten
  end

  def deactivate_oauth_accounts!
    if has_social_errors?
      providers_with_errors = provider.select { |prov| errors[prov.to_sym].any? }
      oauth_accounts.by_provider(providers_with_errors).each do |account|
        account.deactivate!
      end
    end
  end

  def twitter?
    provider.include?('twitter')
  end

  def facebook?
    provider.include?('facebook')
  end

  private

  def provider_inclusion
    provider.each do |provider|
      if provider.present? && !OauthAccount::PROVIDERS.include?(provider)
        errors[:provider] << "Provider #{provider} is not included in the list"
      end
    end
  end

  def should_post_to_twitter?
    twitter? && twitter_post_allowed?
  end

  def should_post_to_facebook?
    facebook? && facebook_post_allowed?
  end

  def twitter_post_allowed?
    profile.twitter_connection.user.followers_count.present? && errors.empty?
  rescue Twitter::Error::Forbidden
    errors[:twitter] << 'Need to connect to Twitter'
    false
  rescue Twitter::Error::Unauthorized
    errors[:twitter] << 'Need to allow posting at Twitter account'
    false
  end

  def facebook_post_allowed?
    posting_allowed = profile.facebook_connection
                             .get_connection('me', 'permissions')
                             .find { |hash| hash.values.include?('publish_actions') }
                             .try(:[], 'status') == 'granted'
    errors[:facebook] << 'Need to allow posting at Facebook account' unless posting_allowed

    posting_allowed && errors.empty?
  rescue Koala::Facebook::AuthenticationError
    errors[:facebook] << 'Need to connect to Facebook'
    false
  end

  def message_length
    errors[:message] << 'for Twitter allows only 140 characters' if twitter? && message.length > 140
    errors[:message] << 'for Facebook allows only 40,000 characters' if facebook? && message.length > 40_000
  end

  def submit_to_facebook
    self.facebook_remote_id = profile.facebook_connection.put_wall_post(message)['id']
  end

  def remove_from_facebook
    profile.account.facebook_connection.try :delete_object, facebook_remote_id
  rescue Koala::Facebook::ClientError
    logger.info 'Post ' + facebook_remote_id + ' has been removed on Facebook page'
  end

  def submit_to_twitter
    self.twitter_remote_id = profile.twitter_connection.update(message).id
  end

  def remove_from_twitter
    profile.account.twitter_connection.try :destroy_tweet, twitter_remote_id
  rescue Twitter::Error::NotFound
    logger.info 'Post ' + twitter_remote_id + ' has been removed on Twitter page'
  end
end
