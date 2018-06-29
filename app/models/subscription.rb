class Subscription < ActiveRecord::Base
  belongs_to :profile
  belongs_to :user

  scope :subscribed, -> { includes(:user).where(users: { subscribed: true }) }
end
