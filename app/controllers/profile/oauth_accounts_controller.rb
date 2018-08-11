class Profile::OauthAccountsController < Profile::BaseController
  inherit_resources

  def destroy
    if resource.deactivate && resource.save
      provider = resource.provider.to_s
      flash[:notice] = "Your #{provider.humanize} account was successfully unlinked from #{app_name}"
      mixpanel_tracker.track_event "deactivate_#{provider}".to_sym
    else
      flash[:alert] = "Can't unlink this account"
    end

    redirect_to profile_oauth_accounts_path
  end

  def fb_pages_reload
    resource.fb_load_pages
    render partial: 'campaing_pages', locals: { oauth_account: resource }
  end

  private

  def permitted_params
    params.permit(profile: %i[facebook_on twitter_on])
  end
end
