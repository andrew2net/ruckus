class CandidateProfile < Profile
  validates :first_name, presence: true, length: { minimum: 2, maximum: 25 }, format_field: true
  validates :last_name,  presence: true, length: { minimum: 2, maximum: 25 }, format_field: true
  validates :name,       presence: true, unless: :new_record?

  before_create :generate_name

  mount_uploader :photo, PhotoUploader

  def photo_url(version = nil)
    photo_url_with_version(version)
  end

  private

  def generate_name
    self.name = [first_name, last_name].join(' ') if name.blank?
  end
end
