class Admin::SenderCouponsController < Admin::BaseController
  inherit_resources
  belongs_to :coupon

  def new
    render :new, layout: false
  end

  def create
    email = params[:account][:email]
    @email_valid = email.present? && EmailValidator.valid?(email)
    CouponsMailer.send_coupon(email, parent).deliver if @email_valid
  end
end
