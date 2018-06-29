class Media::ProfileUpdater::HeroUnit < Media::ProfileUpdater::Base
  private

  def find_medium
    @profile.media.find_by(id: @params[:hero_unit_medium_id])
  end

  def create_medium
    creator.create
  end

  def updating_params
    { hero_unit_medium_id: medium.id, hero_unit: medium.image }
  end

  def creator
    Media::Creator.new(@profile, video_url: @params[:hero_unit_medium][:video_url],
                                 images:    [@params[:hero_unit_medium][:image]])
  end
end
