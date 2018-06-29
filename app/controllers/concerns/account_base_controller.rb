module AccountBaseController
  extend ActiveSupport::Concern

  included do
    layout 'account/admin/main'

    before_action :authenticate_account!
    before_action :set_account_and_profile

    decorates_assigned :profile
  end

  private

  def begin_of_association_chain
    current_account
  end

  def set_account_and_profile
    @account = current_account
    @profile = current_profile
  end
end
