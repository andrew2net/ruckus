class Admin::PagesController < Admin::BaseController
  inherit_resources

  private
  def resource
    @page ||= Page.where(slug: params[:id]).first
  end
  
  def permitted_params
    params.permit(page: [:data])
  end
end
