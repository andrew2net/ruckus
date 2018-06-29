class Front::PressReleasesController < Front::BaseAccountController
  layout false
  inherit_resources
  belongs_to :profile

  private

  def end_of_association_chain
    @end_of_association_chain ||= super.by_position
  end
end
