class Account::InvitationsController < Devise::InvitationsController
  def edit
    resource.invitation_token = params[:invitation_token]

    render :edit, layout: false
  end

  def update
    self.resource = accept_resource
    invitation_accepted = resource.errors.empty?

    yield resource if block_given?

    if invitation_accepted
      flash_message = resource.active_for_authentication? ? :updated : :updated_not_active
      set_flash_message :notice, flash_message if is_flashing_format?
      sign_in(resource_name, resource)
      respond_with resource, location: after_accept_path_for(resource)
    else
      respond_with_navigational(resource){ redirect_to root_path(invitation_token: params[:account][:invitation_token]) }
    end
  end
end
