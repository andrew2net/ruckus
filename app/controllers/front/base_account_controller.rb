class Front::BaseAccountController < Front::BaseController
  before_action :load_profile
  decorates_assigned :profile

  private
  def load_profile
    @profile = parent
  end
end
