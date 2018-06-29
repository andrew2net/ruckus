require 'rails_helper'

describe Admin::SenderCouponsController do
  let(:admin) { create(:admin) }
  let(:coupon) { create(:coupon) }

  before { sign_in(admin) }

  specify 'GET #new' do
    get :new, coupon_id: coupon.id
    expect(response).to render_template :new
  end

  describe 'POST #create' do
    specify 'success' do
      expect {
        xhr :post, :create, coupon_id: coupon.id, account: { email: 'some@test.com' }
      }.to change(ActionMailer::Base.deliveries, :count).by(1)

      expect(response).to render_template :create
    end

    specify 'failure' do
      expect {
        xhr :post, :create, coupon_id: coupon.id, account: { email: '' }
      }.to change(ActionMailer::Base.deliveries, :count).by(0)

      expect(response).to render_template :create
    end
  end
end
