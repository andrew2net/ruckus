module FacebookController
  extend ActiveSupport::Concern
  # If someone clicked on issue link in Facebook and came to this URL
  # - he should get redirected to public page

  included do
    skip_before_action :enable_http_auth, only: [:show]
    before_action :redirect_to_account_path, only: :show
  end

  private

  def redirect_to_account_path
    if request.referrer.present? && request.referrer =~ /(facebook)/
      redirect_to profile_path(resource.profile)
    end
  end
end
