class SetUpNewMediaSorting < ActiveRecord::Migration
  # New media sorting for production

  # define methods
  class TheImageUploader <  CarrierWave::Uploader::Base
    storage :file

    def store_dir
      root_dir = "uploads#{'_test' if Rails.env.test?}"
      "#{root_dir}/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
    end
  end

  class TheCandidate < ActiveRecord::Base
    self.table_name = :candidates

    devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable,
           :validatable, :omniauthable

    has_one :profile, class_name: 'TheProfile', foreign_key: 'candidate_id'
    has_many :media, class_name: 'TheMedia', foreign_key: 'candidate_id'

    def media_stream_items
      media.where.not(position: nil).by_position
    end
  end

  class TheProfile < ActiveRecord::Base
    self.table_name = :profiles
    belongs_to :candidate, class_name: 'TheCandidate'

    serialize :media_stream_ids, Array
  end

  class TheMedia < ActiveRecord::Base
    self.table_name = :media

    belongs_to :candidate, class_name: 'TheCandidate'

    scope :by_position, -> { order('position') }

    mount_uploader :image, SetUpNewMediaSorting::TheImageUploader

    def self.update_positions(ids)
      if ids.is_a?(Array) && ids.any?
        where(id: ids).each do |element|
          element.update_column(:position, ids.map(&:to_s).index(element.id.to_s))
        end
      end
    end
  end

  # migrate
  def up
    TheProfile.all.each do |profile|
      media_stream_ids = profile.media_stream_ids
      Medium.update_positions(media_stream_ids)
    end
  end

  def down
    TheCandidate.all.each do |candidate|
      items = candidate.media_stream_items
      candidate.profile.update media_stream_ids: items.map(&:id)
    end
  end
end
