require 'rails_helper'

describe CouponsMailer do
  let(:coupon) { build(:coupon) }

  specify '#send_coupon' do
    mail = CouponsMailer.send_coupon('test@test.com', coupon)

    expect(mail.to.first).to eq 'test@test.com'
    expect(mail.subject).to end_with ' Discount Code'
    expect(mail.from.first).to eq 'info@example.com'
  end
end
