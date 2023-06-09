require 'rails_helper'

describe Account::CreditCardHoldersController do
  let!(:profile) { create :candidate_profile, credit_card_holder: nil }
  let!(:account) { create :account, profile: profile }

  before { sign_in account }

  describe 'GET new' do
    check_authorizing { get :new, profile_id: profile.id }

    specify do
      get :new, profile_id: profile.id
      expect(response).to render_template :new
    end
  end

  specify 'GET cancel' do
    get :cancel, profile_id: profile.id
    expect(response).to render_template :cancel
  end

  describe 'POST create' do
    let(:params) { { profile_id: profile.id, credit_card_holder: {} } }
    let!(:coupon) { create(:coupon, code: 'somecode') }

    before do
      allow_any_instance_of(De::ProfileUpgrader).to receive(:process).and_return(success?)
      xhr :post, :create, params
    end

    after { expect(response).to render_template 'create' }

    context 'success' do
      let(:success?) { true }
      specify { expect(flash[:notice]).to eq 'Site successfully upgraded' }
    end

    context 'failure' do
      let(:success?) { false }
      specify { expect(flash[:notice]).to be_blank }
    end
  end

  it 'GET edit' do
    get :edit, profile_id: profile.id
    expect(response).to render_template :edit
  end

  describe 'PATCH update' do
    let!(:profile) { create :candidate_profile, :premium }
    let!(:account) { create :account, profile: profile }
    let(:params) { { profile_id: profile.id, credit_card_holder: {
        credit_card_attributes: {
          id: profile.credit_card_holder.credit_card.id,
          number: '4111111111111112',
          cvv: '123',
          month: '01',
          year: '2020'
        }
      }
    }}

    # before do
    #   allow_any_instance_of(De::ProfileUpgrader).to receive(:auth_test).and_return(success?)
    # end

    after { expect(response).to render_template :create }

    context 'success' do
      # let(:success?) { true }
      it do
        expect { xhr :patch, :update, params }.to change {
          profile.credit_card_holder.credit_card.reload.last_four
        }
        expect(flash[:notice]).to eq 'Card successfully updated'
      end
    end

    context 'failure' do
      # let(:success?) { false }
      it do
      allow_any_instance_of(De::ProfileUpgrader).to receive(:auth_test).and_return(false)
        xhr :patch, :update, params
        expect(flash[:notice]).to be_blank
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:card_holder) { create :credit_card_holder, profile: profile }

    before { request.env['HTTP_REFERER'] = 'referer' }

    specify do
      delete :destroy, profile_id: profile.id

      expect(flash[:notice]).to eq 'Site successfully downgraded'
      expect(response).to redirect_to 'referer'
      expect(profile.reload.credit_card_holder).to be_nil
    end
  end
end
