require 'rails_helper'

describe Admin::CouponsController do
  let(:admin) { create(:admin) }

  before { sign_in(admin) }

  describe 'GET #index' do
    let!(:coupon1) { create(:coupon) }
    let!(:coupon2) { create(:coupon) }

    specify do
      get :index
      expect(response).to render_template :index
      expect(assigns(:coupons)).to eq [coupon1, coupon2]
    end
  end

  describe 'GET #new' do
    specify do
      get :new
      expect(response).to render_template :new
    end
  end

  describe 'POST #create' do
    specify 'success' do
      expired_at = Time.now

      expect {
        post :create, coupon: { code: 'somecode', discount: 1.2, expired_at: expired_at }
      }.to change { Coupon.count }.by(1)

      coupon = Coupon.last
      expect(response).to redirect_to admin_coupons_path
      expect(coupon.code).to eq 'somecode'
      expect(coupon.discount).to eq 1.2
      expect(coupon.expired_at.to_i).to eq expired_at.to_i
    end

    specify 'failure' do
      expect {
        post :create, coupon: { code: nil }
      }.to_not change { Coupon.count }

      expect(response).to render_template :new
    end
  end

  describe 'GET #edit' do
    let(:coupon) { create(:coupon) }

    specify do
      get :edit, id: coupon.id
      expect(response).to render_template :edit
    end
  end

  describe 'PATCH #update' do
    let!(:coupon) { create(:coupon, code: 'somecode') }

    specify 'success' do
      patch :update, id: coupon.id, coupon: { code: 'newsomecode' }

      expect(response).to redirect_to admin_coupons_path
    end

    specify 'failure' do
      patch :update, id: coupon.id, coupon: { code: '' }

      expect(response).to render_template :edit
      expect(coupon.reload.code).to eq 'somecode'
    end
  end

  describe 'DELETE #destroy' do
    let!(:coupon) { create(:coupon) }

    describe 'success' do
      specify do
        expect { delete :destroy, id: coupon.id }.to change(Coupon, :count).by(-1)

        expect(response).to redirect_to admin_coupons_path
        expect(flash[:notice]).to eq 'Coupon was successfully destroyed.'
      end
    end
  end
end
