class OauthAuthenticator::Base
  def initialize(profile, auth_data)
    @profile, @auth_data = profile, auth_data
  end

  def process
    return unless @auth_data.present?
    account = @profile.oauth_accounts.find_or_initialize_by(provider: provider_name)
    return unless oauth_account_data_present?
    account.update oauth_account_data #.merge(aasm_state: 'active')
    account
  end

  private

  def oauth_account_data
    {
      uid:              uid,
      oauth_token:      @auth_data['credentials']['token'],
      oauth_secret:     @auth_data['credentials']['secret'],
      oauth_expires_at: oauth_expires_at,
      url:              url
    }
  end

  def oauth_account_data_present?
    uid.present? && url.present?
  end

  def uid
    @auth_data.try(:[], 'uid')
  end
end
