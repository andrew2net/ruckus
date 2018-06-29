class Coupon < ActiveRecord::Base
  include DateFields
  attr_encrypted :code, key: Rails.application.config.encrypted_key

  has_one :credit_card_holder

  validates :code, presence: true, format: { with: /\A[a-z\d]*\Z/i, message: 'invalid code' }
  validates :discount, presence: true

  scope :by_code, -> (code) { where(encrypted_code: new(code: code).encrypted_code) }
  scope :not_expired, -> { where('expired_at IS NULL OR expired_at > ?', Time.now) }
  scope :not_applied, -> do
    left_join = 'LEFT OUTER JOIN "credit_card_holders" ON "credit_card_holders"."coupon_id" = "coupons"."id"'
    joins(left_join).where(credit_card_holders: { id: nil })
  end

  def expired?
    expired_at.present? && expired_at < Time.now
  end
end
