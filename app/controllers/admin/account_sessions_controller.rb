class Admin::AccountSessionsController < Admin::BaseController
  def show
    sign_in resource, bypass: true
    redirect_to profile_root_path
  end

  private
  def resource
    Account.find(params[:id])
  end
end
