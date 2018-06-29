class Profile::PreviewProfilesController < Profile::BaseController
  def show
    @profile = current_account.profiles.where(id: params[:id]).first

    if @profile.present?
      @profile = @profile.decorate(context: { account_editing: false })
      @account = current_account

      render 'accounts/show', layout: 'layouts/account/public/main'
    else
      raise ActionController::RoutingError.new('Not Found')
    end
  end
end
