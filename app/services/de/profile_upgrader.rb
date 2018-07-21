require 'deapi'

class De::ProfileUpgrader
  REMOTE_RECIPIENT_ID = ruckus? ? 'ruckusfees' : 'WINGOPINC'

  # @param credit_card_holder [CreditCardHolder]
  # @param logger [ActiveSupport::Logger]
  def initialize(credit_card_holder, logger = ::ActiveRecord::Base.logger)
    @credit_card_holder = credit_card_holder
    @logger = logger
  end

  # Make a donation and save token.
  # @return [TrueClass, FalseClass]
  def process
    if @credit_card_holder.real?
      if request_successful?
        @credit_card_holder.update(token: de_response['token'], last_payment: Time.current)
        @credit_card_holder.profile.update_column :suspended, false
        send_mail
      else
        set_error
        @credit_card_holder.destroy if @credit_card_holder.persisted?
      end
    end
    @credit_card_holder.errors.empty? && @credit_card_holder.real?
  end

  # Make a test request and save token.
  def auth_test
    if request_successful?(true) && @credit_card_holder.valid? && @credit_card_holder.credit_card.save
      @credit_card_holder.update token: de_response['token']
    else
      set_error
    end
  end

  def set_error
    @credit_card_holder.errors.add(:base, de_response.map(&:last).join(', '))
    @logger.info "credit_card_holder.errors: #{@credit_card_holder.errors.to_a}"
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

  # Performs creatin donation requist.
  # @paran test [TrueClass, FalseClass] true if the requist is auth/test.
  # @return [TrueClass, FalseClass] true if requiest is performed successfully.
  def request_successful?(test = false)
    @logger.info "de_response: #{de_response(test).inspect}"
    de_response.is_a?(Hash) && de_response['token'].present?
  end

  # @paran test [TrueClass, FalseClass] true if the requist is auth/test.
  # @return [Hash] DE response
  def de_response(test = false)
    @de_response ||= DEApi.create_donation(formatted_data(test))
  end

  # @return [TrueClass, FalseClass] true if discount should be applied.
  def apply_discount?
    coupon.present? && !coupon.expired?
  end

  # @paran test [TrueClass, FalseClass] true if the requist is auth/test.
  # @teturn [Hash] data for doantion request.
  def formatted_data(test)
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
      token_request:         @credit_card_holder.token.blank? || test
    }

    if test
      result[:authtest_request] = true
    else
      result[:line_items] = [{ amount: amount, recipient_id: recipient_id }]
    end

    result[:token] = @credit_card_holder.token unless result[:token_request]
    @logger.info "formatted_data_result: #{result}"

    result
  end

  # @return [String] recipient's id
  def recipient_id
    # Set to '1' if you want to create donations in localhost browser
    # '1' is Recipient ID of activated recipient on DemocracyEngine.
    Rails.env.development? ? '1' : REMOTE_RECIPIENT_ID
  end

  # @return [CreditCard]
  def credit_card
    @credit_card_holder.credit_card
  end

  # @return [Coupon]
  def coupon
    @credit_card_holder.coupon
  end
end
