class Profile::MediaController < Profile::BaseController
  layout 'account/admin/modal'

  def destroy
    Media::Destroyer.new(current_profile.media.find(params[:id])).process
    current_profile.reload
  end
end
