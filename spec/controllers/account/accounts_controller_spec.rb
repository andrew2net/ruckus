require 'rails_helper'

describe Account::AccountsController do
  let!(:profile)   { create :candidate_profile, :premium }
  let(:account)    { create :account, profile: profile }
  let!(:ownership) { create :ownership, profile: profile, account: account }

  before { sign_in(account) }

  describe 'GET #index' do
    specify do
      get :index, profile_id: profile.id
      expect(response).to render_template :index
    end
  end

  describe 'GET #new' do
    context 'can' do
      specify do
        xhr :get, :new, profile_id: profile.id
        expect(response).to render_template :new
      end
    end

    context 'cannot' do
      let(:profile) { create(:candidate_profile, credit_card_holder: nil) }

      specify do
        xhr :get, :new, profile_id: profile.id
        expect(response.status).to eq 302
      end
    end
  end

  describe 'POST #create' do
    let!(:account_params) { { email: 'someone@gmail.com' } }

    check_authorizing { xhr :post, :create, profile_id: profile.id, account: account_params }

    context 'can' do
      specify 'valid' do
        expect {
          xhr :post, :create, profile_id: profile.id, account: account_params, ownership_type: 'AdminOwnership'
        }.to change(profile.accounts, :count).by(1)

        Account.where(email: 'someone@gmail.com').first.tap do |new_account|
          expect(new_account.profile).to eq profile
          expect(profile).to have_admin new_account
        end

        expect(response).to render_template :create
      end

      specify 'invalid' do
        expect {
          xhr :post, :create, profile_id: profile.id, account: { email: '' }
        }.to change(profile.accounts, :count).by(0)

        expect(response).to render_template :create
      end

      specify 'duplicate' do
        xhr :post, :create, profile_id: profile.id, account: account_params

        expect {
          xhr :post, :create, profile_id: profile.id, account: account_params
        }.to change(profile.accounts, :count).by(0)

        expect(response).to render_template :create
      end
    end

    context 'cannot' do
      let(:profile) { create(:candidate_profile, credit_card_holder: nil) }

      specify do
        expect {
          xhr :post, :create, profile_id: profile.id, account: account_params
        }.to change(profile.accounts, :count).by(0)

        expect(response.status).to eq 302
      end
    end
  end

  describe 'DELETE destroy' do
    context 'valid account' do
      subject { xhr :delete, :destroy, profile_id: profile.id, id: editor.id }

      before do
        profile.accounts << editor
        expect(AccountMailer).to receive_message_chain(:profile_removal_notification, :deliver)
      end

      context 'last page for editor' do
        let!(:editor) { create :account }

        specify { expect { subject }.to change(profile.accounts, :count).by(-1) }
      end

      context 'not last page for editor' do
        let!(:editor) { create :account, profile: profile }

        specify { expect { subject }.to change(profile.accounts, :count).by(-1) }
        specify { expect { subject }.to change(Profile, :count).by(0) }
        specify { expect { subject }.to change(Ownership, :count).by(-1) }
      end
    end

    context 'unauthorized account' do
      subject { xhr :delete, :destroy, profile_id: profile.id, id: account.id }

      specify do
        expect { subject }.to change(profile.accounts, :count).by(0)
        expect(response).to redirect_to profile_root_path
        expect(response.status).to eq 302
      end
    end
  end
end
