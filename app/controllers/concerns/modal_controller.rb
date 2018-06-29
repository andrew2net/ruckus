module ModalController
  extend ActiveSupport::Concern

  included do
    respond_to :html, :js

    layout 'account/admin/modal'
  end

  def create
    create! do |success, failure|
      success.js { render :show }
    end
  end

  def update
    update! do |success, failure|
      success.js { render :show }
    end
  end

  def destroy
    destroy! do |success, failure|
      success.js { render :destroy }
    end
  end
end
