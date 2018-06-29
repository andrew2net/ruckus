class Account::OwnershipsController < ApplicationController
  inherit_resources
  layout false, only: :edit
  before_action :authenticate_account!
  before_action :authorize_ownership_type_change!

  def update
    # that's because everything else is forbidden
    resource.make_admin if permitted_params[:ownership][:type] == 'AdminOwnership'
    redirect_to account_profiles_path
  end

  private

  def resource
    @ownership ||= Ownership.find_by(account_id: account.id, profile_id: profile.id)
  end

  def authorize_ownership_type_change!
    account.present? && profile.present? && authorize!(:update_ownership_type, account, profile)
  end

  def profile
    @profile ||= Profile.find(params[:profile_id]) if params[:profile_id].present?
  end

  def account
    @account ||= Account.find(params[:account_id]) if params[:account_id].present?
  end

  def permitted_params
    params.permit(ownership: [:type])
  end
end
