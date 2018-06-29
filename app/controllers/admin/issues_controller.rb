class Admin::IssuesController < Admin::BaseController
  inherit_resources
  belongs_to :profile
  before_action :load_resources

  def update
    update! do |success, failure|
      success.html { redirect_to admin_account_profile_issues_path(@account, @profile) }
    end
  end

  def create
    create! do |success, failure|
      success.html { redirect_to admin_account_profile_issues_path(@account, @profile) }
    end
  end

  def destroy
    destroy! do |success, failure|
      success.html { redirect_to admin_account_profile_issues_path(@account, @profile) }
    end
  end

  private
  def load_resources
    @profile = parent.becomes(Profile)
    @account = parent.account
  end

  def permitted_params
    params.permit(issue: [:title, :description, :issue_category_id])
  end
end
