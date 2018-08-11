class OauthAuthenticator::Facebook < OauthAuthenticator::Base
  def provider_name
    'facebook'
  end

  def process
    return unless (oauth_account = super)
    oauth_account.link!
    oauth_account
  end

  private

  def oauth_expires_at
    @oauth_expires_at ||= if @auth_data['credentials']['expires_at']
                            Time.at(@auth_data['credentials']['expires_at'])
                          end
  end

  def url
    "https://www.facebook.com/#{uid}"
  end
end
