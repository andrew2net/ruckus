class DeAccount < ActiveRecord::Base
  attr_accessor :billing_name, :billing_address, :billing_city, :billing_state, :billing_zipcode
  attr_reader :password

  belongs_to :profile
  belongs_to :credit_card

  validates :email, :account_full_name, :account_party, :account_committee_name, :account_committee_id,
            :account_address, :account_city, :account_state, :account_zip, :account_recipient_kind,
            :account_campaign_disclaimer, :bank_account_name, :bank_routing_number, :bank_account_number,
            :contact_first_name, :contact_last_name, :contact_email, :contact_phone, :contact_address, :contact_city,
            :contact_zip, presence: true

  validates :terms, acceptance: { accept: '1' }
  validates :password, presence: true, confirmation: true, on: :create
  validates :password_confirmation, presence: true, on: :create
  validates :bank_account_number, confirmation: true, on: :create
  validates :bank_account_number_confirmation, presence: true, on: :create
  validates :account_state, inclusion: { in: US_STATES_ABBREVIATIONS }
  validates :contact_state, inclusion: { in: US_STATES_ABBREVIATIONS }
  validates :uuid, uniqueness: true, presence: true
  validates :contribution_limit, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 100_000 }, allow_nil: true

  serialize :agreements, Array

  before_validation :generate_de_recipient_id
  after_create :create_de_account

  accepts_nested_attributes_for :credit_card, update_only: true

  def donation_amounts
    0.1..(contribution_limit || 100_000)
  end

  def password=(password)
    @password = password
  end

  def values_for_donation_modal
    case contribution_limit
      when nil, 2500
        [10, 25, 50, 100, 500, 1_000, 2_500]
      else
        increments = [0.01, 0.05, 0.1, 0.25, 0.50, 0.75, 1]
        limit_to_use = contribution_limit > 5000 ? 5000 : contribution_limit
        values = increments.collect{ |value| round_to_closest_5(value * limit_to_use) }
        values.reject!{ |x| x == 0 }
        values.unshift(1) if values[0] < 5 && values[0] != 1 && values.count != 7 # really small cap
        values.uniq
    end
  end

  private

  def round_to_closest_5(value)
    if value > 5 && (value - contribution_limit) > 5
      ((value.to_f / 5).round * 5).to_i
    else
      value.round
    end
  end

  def generate_de_recipient_id
    self.uuid ||= SecureRandom.uuid
  end

  def attributes_for_de
    result = attributes.merge(password: @password).with_indifferent_access
    result[:contribution_limit] += 1 if result[:contribution_limit].present?

    result
  end

  def create_de_account
    unless Rails.env.development? # seeds
      De::RecipientIdCreator.new(attributes_for_de).process
      DeAccountStatusChecker.perform_in(5.minutes, id, Time.now)
    end
  end
end
