class OauthAuthenticator::Facebook < OauthAuthenticator::Base
  def provider_name
    'facebook'
  end

  private

  def oauth_expires_at
    @oauth_expires_at ||= Time.at(@auth_data['credentials']['expires_at'])
  end

  def url
    "https://www.facebook.com/#{uid}"
  end
end
