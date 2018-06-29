class Media::VideoProcessor::Base
  def initialize(medium)
    @medium = medium
    @video_url = @medium.video_url
  end

  def process
    @medium.video_embed_url  = generate_video_embed_url
    @medium.remote_image_url = generate_thumbnail_url
    @medium.save
  end
end
