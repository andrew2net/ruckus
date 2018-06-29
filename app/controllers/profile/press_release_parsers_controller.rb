class Profile::PressReleaseParsersController < Profile::BaseController
  inherit_resources

  def create
    @press_release = current_profile.press_releases.build(url: params[:press_release][:url], build_from_url: true)
    @press_release.valid?

    if parsed_successfully?
      flash.now[:notice] = 'URL was parsed successfully'
    else
      flash.now[:alert] = "Can't parse the URL"
    end
  end

  private

  def parsed_successfully?
    @press_release.present? && !@press_release.errors[:url].any?
  end
  helper_method :parsed_successfully?
end
