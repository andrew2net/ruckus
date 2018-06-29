class Account::ProfilesController < ApplicationController
  inherit_resources

  layout 'account/admin/main'
  before_action :authenticate_account!

  def new
    @profile = current_account.profiles.new
    @profile.type = params[:type].humanize + 'Profile'
    super
  end

  def create
    @profile = current_account.profiles.create(permitted_params[:profile].merge(owner_id: current_account.id))
    if @profile.persisted?
      redirect_to account_profiles_path
    else
      type = permitted_params[:profile][:type].gsub(/profile/i, "").downcase
      redirect_to new_account_profile_path(type: type)
      flash[:alert] = @profile.errors.full_messages.join('<br/>').html_safe
    end
  end

  def update
    current_account.update permitted_params[:account]
    redirect_to account_profiles_path
  end

  private
  def begin_of_association_chain
    @begin_of_association_chain ||= current_account
  end

  def end_of_association_chain
    @end_of_association_chain ||= super.includes([:domain, :credit_card_holder])
  end

  def permitted_params
    params.permit(profile: [:name, :first_name, :last_name, :office, :type],
                  account: [:profile_id])
  end
end
