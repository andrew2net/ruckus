class Profile::SocialsController < Profile::BaseController
  inherit_resources
  layout 'account/admin/modal'

  include ProfileableController

  def update
    update! do |success, failure|
      success.html do
        redirect_to profile_oauth_accounts_path
      end
      failure.html { redirect_to profile_oauth_accounts_path }
    end
  end

  private

  def permitted_params
    params.permit(profile: [:facebook_on, :twitter_on, :facebook_public_page_url])
  end
end
