class Admin::DonationsController < Admin::BaseController
  inherit_resources

  private

  def collection
    @donations ||= end_of_association_chain.includes(profile: :domain)
  end
end
