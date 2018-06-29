class OauthAuthenticator::Twitter < OauthAuthenticator::Base
  def provider_name
    'twitter'
  end

  private

  def oauth_expires_at
    @oauth_expires_at ||= 10.years.from_now.to_date
  end

  def url
    @auth_data['info']['urls']['Twitter']
  end
end
