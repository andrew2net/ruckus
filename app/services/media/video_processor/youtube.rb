class Media::VideoProcessor::Youtube < Media::VideoProcessor::Base
  private

  def generate_thumbnail_url
    # E.g.: http://img.youtube.com/vi/2Abk1jAONjw/hqdefault.jpg
    url = "http://img.youtube.com/vi/#{@vid_id}/default.jpg"

    begin
      url = Yt::Video.new(url: @video_url).thumbnail_url
    rescue => e
    end

    url
  end

  def generate_video_embed_url
    @vid_id = nil
    video_embed_url = nil
    vid_regex = /(?:youtube.com|youtu.be).*(?:\/|v=)([a-zA-Z0-9_-]+)/

    if @video_url =~ vid_regex
      @vid_id = $1
      video_embed_url = '//www.youtube.com/embed/' + @vid_id
    end

    video_embed_url
  end
end
