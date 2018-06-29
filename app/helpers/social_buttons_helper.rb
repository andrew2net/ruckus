module SocialButtonsHelper
  def load_facebook_init
    render 'shared/social_buttons/facebook_init'
  end

  def load_twitter_init
    render 'shared/social_buttons/twitter_init'
  end

  def facebook_like(href)
    data = {
      href:        href,
      colorscheme: 'light',
      layout:      'button',
      action:      'like',
      show_faces:  false,
      share:       false,
      width:       50
    }

    content_tag :div, '', class: 'fb-like', data: data
  end

  def facebook_like_iframe(href)
    facebook_params = {
      href: href,
      width: 50,
      layout: 'button',
      action: 'like',
      show_faces: false,
      share: false,
      height: 35,
      appId: OAUTH_PROVIDERS['facebook']['client_id']
    }.to_param

    iframe_params = {
      src: "//www.facebook.com/plugins/like.php?#{facebook_params}",
      scrolling: 'no',
      frameborder: '0',
      style: 'border:none; overflow:hidden; height:35px;',
      allowTransparency: 'true'
    }

    content_tag :iframe, '', iframe_params
  end

  def twitter_follow(profile)
    data = { show_count: false,
             show_screen_name: false }

    link_to 'Follow', profile.twitter_url, class: 'twitter-follow-button', data: data
  end

  def facebook_follow_button_params(profile)
    params = {
      href: profile.facebook_account.url,
      width: 21,
      height: 21,
      colorscheme: :light,
      layout: :button_count,
      show_faces: false,
      appId: OAUTH_PROVIDERS['facebook']['client_id']
    }.to_param
    '//www.facebook.com/plugins/follow.php?' + params
  end

  def twitter_share_link(profile, text)
    params = {
      source: 'webclient',
      text: text[0, 80],
      via: "#{profile.twitter_id} : #{profile_path(profile)}"
    }.to_param
    'https://twitter.com/intent/tweet?' + params
  end

  def facebook_share_text_link(profile, text)
    params = {
      t: text[0, 80],
      u: profile.facebook_public_page_url.present? ? profile.facebook_public_page_url : profile_path(profile)
    }.to_param
    'https://www.facebook.com/sharer/sharer.php?' + params
  end

  def facebook_share_link(resource)
    params = {
      u: resource_url(resource)
    }.to_param
    'https://www.facebook.com/sharer/sharer.php?' + params
  end
end
