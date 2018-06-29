class Front::SocialPostsController < Front::BaseAccountController
  include FacebookController
  inherit_resources
  belongs_to :profile
  layout false

  before_action :load_resources

  private

  def load_resources
    @profile = parent
    @account = parent.account
  end

  def end_of_association_chain
    @end_of_association_chain ||= super.order(created_at: :desc)
  end

  # TODO: remove this after moving Social Posts to Profile
  def redirect_to_account_path
    if request.referrer.present? && request.referrer !~ /(lvh|qa1-ruck|qa2-ruck|ruck)/
      redirect_to profile_path(resource.profile)
    end
  end
end
