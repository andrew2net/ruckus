require 'deapi'

class De::ProfileUpgrader
  REMOTE_RECIPIENT_ID = ruckus? ? 'ruckusfees' : 'WINGOPINC'

  def initialize(credit_card_holder, logger = ::ActiveRecord::Base.logger)
    @credit_card_holder = credit_card_holder
    @logger = logger
  end

  def process
    if @credit_card_holder.real?
      if request_successful?
        @credit_card_holder.update(token: de_response['token'], last_payment: Time.current)
        @credit_card_holder.profile.update_column :suspended, false
        send_mail
      else
        @credit_card_holder.errors.add(:base, de_response.map(&:last).join(', '))
        @logger.info "credit_card_holder.errors: #{@credit_card_holder.errors.to_a}"
        @credit_card_holder.destroy if @credit_card_holder.persisted?
      end
    end
    @credit_card_holder.errors.empty? && @credit_card_holder.real?
  end

  def check_coupon
    @credit_card_holder.valid?
    code_errors = @credit_card_holder.errors[:coupon_code].first
    @credit_card_holder.errors.clear
    @credit_card_holder.credit_card.errors.clear
    @credit_card_holder.errors[:coupon_code] << code_errors if code_errors.present?
  end

  def amount
    result = 20
    result *= (1 - coupon.discount.to_f / 100) if apply_discount?

    "$%g" % result.round(2)
  end

  private

  def send_mail
    profile = @credit_card_holder.profile
    emails  = profile.accounts.pluck(:email)
    PremiumMailer.delay.profile_upgrading_notification(emails, profile, amount)
  end

  def request_successful?
    @logger.info "de_response: #{de_response.inspect}"
    de_response.is_a?(Hash) && de_response['token'].present?
  end

  def de_response
    @de_response ||= DEApi.create_donation(formatted_data)
  end

  def apply_discount?
    coupon.present? && !coupon.expired?
  end

  def formatted_data
    # Set to '1' if you want to create donations in localhost browser
    # '1' is Recipient ID of activated recipient on DemocracyEngine.
    recipient_id = Rails.env.development? ? '1' : REMOTE_RECIPIENT_ID

    result = {
      donor_first_name:      @credit_card_holder.first_name,
      donor_last_name:       @credit_card_holder.last_name,
      donor_city:            @credit_card_holder.city,
      donor_state:           @credit_card_holder.state,
      donor_zip:             @credit_card_holder.zip,
      donor_address1:        @credit_card_holder.address,
      cc_number:             credit_card.number,
      cc_verification_value: credit_card.cvv,
      cc_month:              credit_card.month,
      cc_year:               credit_card.year,
      cc_first_name:         @credit_card_holder.first_name,
      cc_last_name:          @credit_card_holder.last_name,
      token_request:         @credit_card_holder.token.blank?,
      line_items: [{
        amount:       amount,
        recipient_id: recipient_id
      }]
    }
    result[:token] = @credit_card_holder.token unless result[:token_request]
    @logger.info "formatted_data_result: #{result}"

    result
  end

  def credit_card
    @credit_card_holder.credit_card
  end

  def coupon
    @credit_card_holder.coupon
  end
end
