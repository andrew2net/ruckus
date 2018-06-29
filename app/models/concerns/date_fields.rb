raise "Remove this concern (#{__FILE__})" if Rails.version >= '5'

# It returns Rails3 and Rails5 default behaviour. Remove that concern after updating to Rails5
module DateFields
  extend ActiveSupport::Concern

  included do
    define_date_writers
  end

  module ClassMethods
    private

    def define_date_writers
      date_attributes.each do |attribute|
        define_method("#{attribute}=") do |arg|
          begin
            write_attribute(attribute, arg)
          rescue ArgumentError
            nil
          end
        end
      end
    end

    private

    def date_attributes
      types = [:date, :datetime]
      columns_hash.select { |_, v| types.include?(v.type) }.keys
    end
  end
end
