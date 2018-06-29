class Account::AccountsController < ApplicationController
  inherit_resources
  layout 'account/admin/main'
  before_action :authenticate_account!
  before_action :authorize_creation!, only: [:new, :create]
  respond_to :js
  belongs_to :profile
  has_scope :with_deleted, default: true

  def create
    @account = parent.invite_editor(permitted_params[:account][:email])
    parent.ownerships.where(account_id: @account.id).update_all type: permitted_params[:ownership_type]
    flash[:notice] = 'Account was successfully invited'
  end

  def destroy
    authorize! :destroy, resource, parent

    if resource.profiles.count == 1
      resource.destroy
    else
      resource.ownerships.where(profile_id: parent.id).destroy_all
    end
    AccountMailer.profile_removal_notification(resource, parent, resource.destroyed?).deliver
  end

  private
  def authorize_creation!
    authorize! :create, Account.new, parent
  end

  def end_of_association_chain
    @end_of_association_chain ||= super.with_first(current_account.id).admins_first
  end

  def permitted_params
    params.permit(:ownership_type, account: [:email])
  end
end
