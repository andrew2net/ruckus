class Media::Creator
  def initialize(profile, options = {})
    @profile, @options = profile, options
  end

  def create
    save_video_if_can || save_images_if_can
  end

  private

  def save_video_if_can
    video_url = @options[:video_url]
    if video_url.present?
      medium = @profile.media.new(video_url: video_url)

      if medium.valid?
        medium.save
        video_processor(medium).process
        medium
      end

    end
  end

  def save_images_if_can
    images = @options[:images]
    images.map { |image| @profile.media.create(image: image) }.last if images.present?
  end

  def video_processor(medium)
    case medium.video_url
    when /.*vimeo.*/
      Media::VideoProcessor::Vimeo.new(medium)
    when /.*youtube.*/
      Media::VideoProcessor::Youtube.new(medium)
    end
  end
end
