class Admin::DomainsController < Admin::BaseController
  inherit_resources

  def destroy
    if resource.destroy
      redirect_to admin_domains_path, notice: 'Domain was successfully deleted.'
    else
      flash.now[:alert] = "Can't remove this domain."
      render :show
    end
  end

  private

  def collection
    @domains ||= end_of_association_chain.joins(profile: :admin_ownerships).uniq
                                         .where(ownerships: { account_id: Account.pluck(:id) })
                                         .order(id: :desc)
                                         .includes(profile: { admin_ownerships: :account })
  end

  def permitted_params
    params.permit(domain: [:name, :profile_id, :internal])
  end
end
