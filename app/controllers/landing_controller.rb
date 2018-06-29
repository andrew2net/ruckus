class LandingController < ApplicationController
  def index
    redirect_to profile_root_path if account_signed_in?
  end

  def message
    @profile = Profile.find(params[:profile_id])
  end
end
