class Medium < ActiveRecord::Base
  include Sortable

  belongs_to :profile
  validate :presence_of_image_or_video_url
  validates :video_url, url_format: { format: :youtube_or_vimeo_video, existence: true }, allow_blank: true

  mount_uploader :image, ImageUploader

  scope :only_images,   -> { where(video_url: nil) }
  scope :only_videos,   -> { where.not(video_url: nil) }
  scope :ruckus_global, -> { where(profile_id: nil) }
  scope :with_profile,  -> { where.not(profile_id: nil) }

  def ruckus?
    profile_id.blank?
  end

  def active?
    position.present?
  end

  def video?
    video_url.present?
  end

  def width
    image.large_thumb.get_version_dimensions[:width]
  end

  def height
    image.large_thumb.get_version_dimensions[:height]
  end

  private

  def presence_of_image_or_video_url
    if image.blank? && video_url.blank?
      errors.add(:base, 'Specify either image or video URL')
    end
  end
end
