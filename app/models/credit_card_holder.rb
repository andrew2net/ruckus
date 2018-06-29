class CreditCardHolder < ActiveRecord::Base
  attr_accessor :coupon_code

  belongs_to :profile
  belongs_to :credit_card
  belongs_to :coupon

  validates :city, :address, presence: true
  validates :state, inclusion: US_STATES_ABBREVIATIONS, presence: true
  validates :zip, zip_format: true, presence: true
  validates :first_name, presence: true, length: { minimum: 2, maximum: 25 }, format_field: true
  validates :last_name,  presence: true, length: { minimum: 2, maximum: 25 }, format_field: true
  validate :validate_code

  accepts_nested_attributes_for :credit_card

  def real?
    valid? && profile.accounts.exists?
  end

  private

  def validate_code
    if coupon_code.present?
      coupon = Coupon.not_expired.by_code(coupon_code).first

      if coupon.present?
        self.coupon = coupon
      else
        errors.add(:coupon_code, 'invalid code')
      end
    end
  end
end
