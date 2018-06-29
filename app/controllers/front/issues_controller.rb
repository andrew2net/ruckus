class Front::IssuesController < Front::BaseAccountController
  include FacebookController
  layout false
  inherit_resources
  belongs_to :profile
  respond_to :html, :js
  before_action :load_resource, only: [:show, :index]

  def index
    @account_editing = request.referrer.present? && request.referrer.include?(profile_root_path)
    @category_id = params[:category_id] || :all

    render 'index'
  end

  def show
    index! do |format|
      format.html { render 'show', layout: false }
    end
  end

private

  def load_resource
    @categories = parent.allowed_categories
  end
end
