class PressReleaseImage < ActiveRecord::Base
  belongs_to :profile
  belongs_to :press_release,
             -> (press_release_image) { where(profile_id: press_release_image.profile_id) },
             foreign_key: :press_release_url,
             primary_key: :url

  validates :profile,           presence: true
  validates :press_release_url, presence: true

  mount_uploader :image, PressReleaseImageUploader

  scope :active,   -> { where(active: true) }
  scope :inactive, -> { where(active: [false, nil]) }
end
