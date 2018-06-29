require 'rails_helper'

describe Admin::ProfilesController do
  let!(:admin)     { create :admin }
  let!(:profile)   { create :candidate_profile }
  let!(:account)   { create :account, profile: profile }
  let!(:ownership) { create :ownership, profile: profile, account: account }

  describe 'actions_templates' do
    before { sign_in admin }

    specify 'GET #index' do
      get :index, account_id: account.id
      expect(response).to render_template :index
    end

    specify 'GET #new' do
      get :new, account_id: account.id
      expect(response).to render_template :new
    end

    specify 'GET #edit' do
      get :edit, id: profile.id, account_id: account.id
      expect(response).to render_template :edit
    end

    specify 'GET #show' do
      get :show, id: profile.id, account_id: account.id
      expect(response).to render_template :show
    end

    specify 'DELETE #destroy' do
      delete :destroy, id: profile.id, account_id: account.id

      expect(response).to redirect_to admin_accounts_path
      expect(Profile.count).to be_zero
    end
  end

  context 'create_profile_results' do
    before { sign_in admin }

    let(:params) do
      { name: 'Some Dude' }
    end

    specify 'create profile' do
      expect { post :create, profile: params, account_id: account.id }.to change(Profile, :count).by(1)
      expect(response).to redirect_to admin_account_profile_path(account, Profile.last)
    end
  end

  describe 'as admin' do
    before { sign_in admin }

    specify 'GET show' do
      get :show, account_id: account.id, id: profile.id
      expect(response).to render_template :show
    end
  end

  describe 'as account' do
    before { sign_in account }

    specify 'GET show' do
      get :show, account_id: account.id, id: profile.id
      expect(response).to redirect_to new_admin_session_path
    end
  end
end
