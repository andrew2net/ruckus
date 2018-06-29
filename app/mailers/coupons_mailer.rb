class CouponsMailer < BaseMailer
  def send_coupon(email, coupon)
    @coupon = coupon
    @email = email
    mail(to: email, subject: "Your #{app_name} Discount Code")
  end
end
