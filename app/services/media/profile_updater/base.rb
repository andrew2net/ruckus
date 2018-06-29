class Media::ProfileUpdater::Base
  def initialize(profile, params)
    @profile, @params = profile, params[:profile]
  end

  def process
    @profile.update(updating_params) if medium.present? && medium.image.present?
  end

  private

  def medium
    @medium ||= find_medium || create_medium
  end
end
