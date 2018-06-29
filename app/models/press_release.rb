class PressRelease < ActiveRecord::Base
  include Cacheable
  include Sortable

  belongs_to :profile

  has_many :press_release_images,
           -> (press_release) { where(profile_id: press_release.profile_id) },
           foreign_key: :press_release_url,
           primary_key: :url,
           dependent:   :destroy

  validates :profile,   presence: true
  validates :title,     presence: true
  validates :url,       presence: true, url_format: { existence: true }, uniqueness: { scope: :profile_id }

  attr_writer :active_image_id
  attr_accessor :build_from_url

  after_save :set_active_image!
  after_create :make_it_first_in_the_list
  before_validation :new_from_url

  def new_from_url
    if url.present? && build_from_url
      parser = PressReleaseParser.new(url)
      attrs = parser.scrape

      self.errors.add(:url, parser.errors[:url]) unless parser.errors.blank?
      self.create_images(parser.images)
      self.title ||= attrs[:title]
      self.page_title ||= attrs[:page_title]
      self.page_date ||= attrs[:page_date]
      self.url ||= attrs[:url]
    end
  end

  def create_images(image_files)
    press_release_images.destroy_all
    image_files.each do |file|
      image = press_release_images.new(image: file)
      image.save
    end
  end

  def active_image
    cached_method(:active_image) { press_release_images.active.first || press_release_images.first }
  end

  def active_image_id
    active_image.try(:id)
  end

  def display_page_thumbnail?
    page_thumbnail_enabled? && active_image.present?
  end

  def display_page_title?
    page_title_enabled? && page_title.present?
  end

  def display_page_date?
    page_date_enabled? && page_date.present?
  end

private

  def set_active_image!
    if @active_image_id.present?
      press_release_images.active.update_all(active: false)
      press_release_images.where(id: @active_image_id).update_all(active: true)
    end
  end

  def make_it_first_in_the_list
    old_list = profile.press_releases.by_position.pluck(:id)
    new_list = old_list.unshift(id)
    PressRelease.update_positions(new_list)
  end
end
