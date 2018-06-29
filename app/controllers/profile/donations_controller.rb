class Profile::DonationsController < Profile::BaseController
  inherit_resources

  private

  def begin_of_association_chain
    current_profile
  end

  def end_of_association_chain
    @end_of_association_chain ||= super.order(:created_at)
  end
end
