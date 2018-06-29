class Media::VideoProcessor::Vimeo < Media::VideoProcessor::Base
  private

  def video
    @video ||= ::Vimeo::Simple::Video.info(extract_video_id).parsed_response
  end

  def generate_video_embed_url
    "//player.vimeo.com/video/#{extract_video_id}"
  end

  def generate_thumbnail_url
    # E.g.: http://b.vimeocdn.com/ts/277/946/277946825_640.jpg
    video.first["thumbnail_large"]
  end

  def extract_video_id
    # E.g. http://vimeo.com/40234826?whatever=9384739473 -> 40234826
    @video_url.scan(/\d*/).reject(&:blank?).first
  end
end
