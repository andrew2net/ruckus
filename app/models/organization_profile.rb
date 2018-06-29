class OrganizationProfile < Profile
  validates :name, presence: true, length: { minimum: 2, maximum: 255 }, format_field: true

  mount_uploader :photo, LogoUploader

  def photo_url(version = nil)
    photo_url_with_version(version)
  end
end
