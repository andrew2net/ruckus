OmniAuth.config.test_mode = true

OmniAuth.config.mock_auth[:twitter] = OmniAuth::AuthHash.new(
  {
    uid: 'uid',
    credentials: {
      token: 'token',
      secret: 'secret'
    },
    info: {
      urls: {
        Twitter: 'https://twitter.com/fillwerrell'
      }
    }
  }
)

OmniAuth.config.mock_auth[:facebook] = OmniAuth::AuthHash.new(
  {
    uid: 'uid',
    credentials: {
      token: 'token',
      secret: 'secret',
      expires_at: 1321747205
    }
  }
)
