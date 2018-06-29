require 'rails_helper'

describe Profile::DeAccountsController do
  let(:profile)     { create :candidate_profile }
  let!(:account)    { create :account, profile: profile }
  let!(:agreements) { ['agreement 1', 'agreement 2'] }

  before { sign_in account }

  describe 'GET #new' do
    specify 'success' do
      expect_any_instance_of(MixpanelTracker).to receive(:add_event).with(:enable_donation_start)
      get :new
      expect(response).to render_template :new
    end
  end

  describe 'POST #create' do
    let!(:parameters) { attributes_for(:de_account).merge(agreements: agreements) }

    it 'can create' do
      expect_any_instance_of(MixpanelTracker).to receive(:add_event).with(:enable_donation_finish)
      post :create, de_account: parameters

      profile.reload.de_account.tap do |de_account|
        expect(de_account).to be_present
        expect(de_account.uuid).to be_present
        expect(de_account.agreements).to eq agreements
      end

      expect(response).to redirect_to edit_profile_page_option_path
      expect(flash[:notice]).to eq 'Payment account was successfully created.'
    end

    it 'rejects account id' do
      post :create, de_account: parameters.merge(account_id: 3829)

      expect(profile.reload.de_account).to be_present
    end


    it 'does not create duplicate' do
      post :create, de_account: parameters
      post :create, de_account: parameters

      expect(DeAccount.count).to eq 1
    end

    it 'renders index if error happens' do
      expect_any_instance_of(MixpanelTracker).to receive(:add_event).with(:enable_donation_error)
      post :create, de_account: parameters.except(:account_full_name)

      expect(profile.de_account).to be_nil
      expect(response).to render_template 'new'
    end
  end

  describe 'GET #show' do
    specify 'without DE account' do
      expect { get :show }.to raise_error ActionController::RoutingError
    end

    context 'with DE account' do
      let!(:de_account) { create(:de_account, profile: profile) }

      specify do
        get :show
        expect(response).to render_template 'show'
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:de_account) { create(:de_account, profile: profile) }

    specify do
      expect { delete :destroy }.to change{ DeAccount.count }.by(-1)
      expect(response).to redirect_to edit_profile_page_option_path
    end
  end
end
