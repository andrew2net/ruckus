class Front::SupportMessagesController < Front::BaseController
  inherit_resources
  before_action :load_content, only: [:show]

  respond_to :js

  def create
    create! do |success, failure|
      success.js do
        load_content
        render 'show'
      end
    end
  end

  private

  def permitted_params
    params.permit(support_message: [:subject, :email, :name, :message])
  end

  def load_content
    @content = Page.find_by(slug: 'contact').try(:data).to_s.html_safe
  end
end
