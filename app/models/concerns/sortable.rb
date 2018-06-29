module Sortable
  extend ActiveSupport::Concern

  included do
    scope :by_position, -> { order('position') }
    scope :by_position_desc, -> { order('position DESC') }
  end

  module ClassMethods
    def update_positions(ids, options = {})
      if ids.is_a?(Array) && ids.any?
        ids.map!(&:to_i)
        params = { id: ids }
        params.merge!(profile_id: options[:profile_id]) if options[:profile_id].present?

        where(params).each { |item| item.update_column(:position, ids.index(item.id)) }
      end
    end
  end
end
