class Profile::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def twitter
    process_request(OauthAuthenticator::Twitter)
  end

  def facebook
    process_request(OauthAuthenticator::Facebook)
  end

  private

  def process_request(authenticator_class)
    authenticator = authenticator_class.new(current_profile, request.env['omniauth.auth'])
    if authenticator.process
      mixpanel_tracker.track_event "sync_#{authenticator.provider_name}"
      flash[:notice] = "You are connected to #{authenticator.provider_name.titleize}"
    else
      flash[:alert] = current_profile.errors.full_messages.to_sentence
    end
    redirect_to profile_oauth_accounts_path
  end
end
