class Media::ProfileUpdater::DefaultBackgroundImage < Media::ProfileUpdater::BackgroundImage
  def initialize(profile)
    @profile = profile
    @params = {}
  end

  private

  def find_medium
    Medium.find_by(image: 'Farm_2.jpg')
  end
end
