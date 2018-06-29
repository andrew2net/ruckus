class Request < ActiveRecord::Base
  include Chartable

  belongs_to :requestable, polymorphic: true

  serialize :data
end
