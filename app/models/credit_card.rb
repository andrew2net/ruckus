class CreditCard < ActiveRecord::Base
  attr_accessor :number, :cvv, :month, :year

  has_one :credit_card_holder
  has_many :donations

  validates :number, format: /\A\d{15,16}\z/, if: :new_record?
  validates :cvv, format: /\A\d{3,4}\z/, if: :new_record?
  validates :month, inclusion: MONTHS, if: :new_record?
  validates :year, inclusion: YEARS, if: :new_record?
  validate :card_type, if: :new_record?
  validate :expiry_date, if: :new_record?

  scope :about_to_expire, -> { where(exp_date: [Date.today + 1.day, Date.today + 7.days]) }

  before_save :save_last_four
  before_save :save_exp_date

  private

  def save_last_four
    self.last_four = number.split(//).last(4).join
  end

  def save_exp_date
    self.exp_date = Date.parse "#{month}/#{year}"
  end

  def expiry_date
    if errors.blank? && month.present? && year.present?
      time = Time.parse("#{month}/#{year}")
      errors[:base] << 'Card Expired' if time < Time.now
    end
  end

  def card_type
    # card type (number length + cvv)
    errors[:number] << 'Credit Card Invalid' if !valid_non_amex_card? && !valid_amex_card?
  end

  def valid_amex_card?
    # AMEX
    @number =~ /\A3\d{14}\z/ && @cvv =~ /\A\d{4}\z/
  end

  def valid_non_amex_card?
    # VISA/MC/Discover
    @number =~ /\A(4|5|6)\d{15}\z/ && @cvv =~ /\A\d{3}\z/
  end
end
