class Profile::BuildersController < Profile::BaseController
  layout 'account/admin/builder'
  before_action :load_resources, only: [:show]

  private
  def load_resources
    @domain = current_profile.domain
  end
end
