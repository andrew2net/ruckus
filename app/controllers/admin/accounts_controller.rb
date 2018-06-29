class Admin::AccountsController < Admin::BaseController
  inherit_resources
  before_action :load_info, only: :show
  before_action :load_last_visits, only: :index

  has_scope :with_deleted, default: true, only: :index, type: :boolean
  has_scope :only_deleted, only: :index, type: :boolean
  has_scope :by_id

  def index
    scope = %w(all inactive).include?(params[:status]) ? params[:status] : 'active'
    @accounts = collection.send(scope)
  end

  def new
    @account = Account.new
    @account.profiles.new
  end

  def create
    @account = Account.new(update_params)
    create! { admin_accounts_path }
  end

  def update
    if params[:account][:password].blank?
      resource.update_without_password(update_params)
    else
      resource.update_attributes(update_params)
    end
    if resource.errors.blank?
      redirect_to admin_accounts_path
    else
      render 'edit'
    end
  end

  def destroy
    destroy! { admin_accounts_path(superadmin: 1) }
  end

  def list_logins
    @logins ||= resource.logins
  end

  private

  def load_info
    @account = resource
    @profile = resource.profiles.first
  end

  def collection
    apply_scopes(Account).order(created_at: :desc)
  end

  def end_of_association_chain
    Account.with_deleted
  end

  def permitted_params
    params.permit(account: [:email, :username, :password, :password_confirmation])
  end

  def update_params
    params.require(:account).permit(:email, :username, :password, :password_confirmation, :deleted_at)
  end

  def load_last_visits
    account_ids = collection.pluck(:id).uniq

    @donations_raised = Account.where(id: account_ids)
                               .joins(profiles: :donations)
                               .group('accounts.id')
                               .sum(:amount)

    @last_visits = Account.where(id: account_ids)
                          .joins(profiles: { domains: :visits })
                          .group('accounts.id')
                          .maximum('requests.created_at')
  end
end
