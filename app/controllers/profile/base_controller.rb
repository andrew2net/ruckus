class Profile::BaseController < ApplicationController
  layout 'account/admin/main'
  before_action :authenticate_account!

  private

  def profile_value_changed?(attr, params)
    params.present? && !params[attr].nil? && current_profile[attr] != params[attr]
  end
end
