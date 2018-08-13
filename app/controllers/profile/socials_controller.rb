class Profile::SocialsController < Profile::BaseController
  inherit_resources
  layout 'account/admin/modal'

  include ProfileableController

  def update
    update! do |success, failure|
      if params[:oauth_account] && permitted_params[:profile].key?(:facebook_on)
        oa = resource.facebook_account
        oa.update oauth_account_params
        if oa.campaing_pages.where(publishing_on: true).any?
          oa.activate!
        else
          oa.link!
        end
      end
      success.html do
        redirect_to profile_oauth_accounts_path
      end
      failure.html { redirect_to profile_oauth_accounts_path }
    end
  end

  private

  def permitted_params
    params.permit(profile: %i[facebook_on twitter_on facebook_public_page_url])
  end

  def oauth_account_params
    params.require(:oauth_account).permit campaing_pages_attributes: %i[id publishing_on]
  end
end
