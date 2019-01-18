class Donation < ActiveRecord::Base
  include Chartable

  belongs_to :profile
  belongs_to :credit_card

  validates_presence_of :donor_first_name, :donor_last_name, :donor_email, :donor_phone,
                        :donor_address_1, :donor_city, :donor_state, :donor_zip,
                        :amount, :profile_id

  validates :donor_state, inclusion: { in: US_STATES_ABBREVIATIONS }
  validates :employer_state, inclusion: { in: US_STATES_ABBREVIATIONS }, allow_nil: :true
  validates :agree_with_terms, acceptance: { accept: '1' }
  validates :donor_zip, zip_format: true
  validates :employer_zip, zip_format: true
  validates :amount, amount_inclusion: true
  validates :transaction_uri, url_format: true

  accepts_nested_attributes_for :credit_card, update_only: true

  after_validation :sync_with_de

  def self.amount_by(period, start = 1.year.ago)
    case period
    when :week
      amount_by_week(start)
    else
      amount_by_month(start)
    end
  end

  def self.amount_by_month(start = 1.year.ago)
    where(created_at: start.beginning_of_month..Time.now)
      .group("DATE(DATE_TRUNC('month', created_at))")
      .select("DATE(DATE_TRUNC('month', created_at)) as created_at, SUM(amount) as total_amount")
      .order("created_at")
  end

  def self.amount_by_week(start = 1.year.ago)
    where(created_at: start.beginning_of_month..Time.now)
      .group("DATE(DATE_TRUNC('week', created_at))")
      .select("DATE(DATE_TRUNC('week', created_at)) as created_at, SUM(amount) as total_amount")
      .order("created_at")
  end

  def donor_name
    [donor_first_name, donor_last_name].join(' ')
  end

  def donor_full_address
    [donor_address_1, donor_city, donor_zip, donor_state].join(' ')
  end

  def employer_full_address
    [employer_address, employer_city, employer_zip, employer_state].join(' ')
  end

  private

  def fee_tier
    profile.premium? ? 2 : 1
  end

  def attributes_for_de
    attributes.merge(profile_id: profile_id,
                     cc_number:  credit_card.number,
                     cc_cvv:     credit_card.cvv,
                     cc_month:   credit_card.month,
                     cc_year:    credit_card.year,
                     fee_tier:   fee_tier).with_indifferent_access
  end

  def sync_with_de
    begin
      response = De::DonationCreator.new.process(attributes_for_de)

      self.transaction_guid = response['line_items'].first['transaction_guid']
      self.transaction_uri = response['line_items'].first['transaction_uri']
    rescue TypeError
      response.collect(&:last).each do |de_error_message|
        errors.add(:base, de_error_message)
      end
    end if errors.empty? && !Rails.env.development?
  end
end
