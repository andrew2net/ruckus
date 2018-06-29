require 'rails_helper'

describe Account::ProfilesController do
  let!(:profile)  { create :candidate_profile }
  let!(:account)  { create :account, profile: profile }
  let!(:profile2) { create :candidate_profile }

  before { sign_in account }

  xdescribe 'GET index' do
    check_authorizing { get :index }

    specify do
      get :index
      expect(response).to render_template :index
      expect(assigns(:profiles)).to match_array [profile, profile2]
    end
  end

  describe 'GET new' do
    check_authorizing { get :new }

    specify do
      get :new, type: :candidate
      expect(response).to render_template :new
      expect(assigns(:profile).type).to eq 'CandidateProfile'
    end

    specify do
      get :new, type: :organization
      expect(response).to render_template :new
      expect(assigns(:profile).type).to eq 'OrganizationProfile'
    end
  end

  describe 'POST create' do
    context 'candidate' do
      let!(:valid_params) { { first_name: 'John', last_name: 'Smith', office: 'Senator', type: 'CandidateProfile' } }
      check_authorizing { post :create, profile: valid_params }

      specify 'success' do
        expect {
          post :create, profile: valid_params
        }.to change(account.candidate_profiles, :count).by (1)

        expect(Profile.last.owner).to eq account
        expect(response).to redirect_to(account_profiles_path)
      end

      specify 'failure' do
        expect {
          post :create, profile: valid_params.merge(first_name: '')
        }.to change(account.candidate_profiles, :count).by (0)

        expect(response).to redirect_to(new_account_profile_path(type: 'candidate'))
      end
    end

    context 'organization' do
      let!(:valid_params) { { name: 'MyOrg', type: 'OrganizationProfile' } }
      check_authorizing { post :create, profile: valid_params }

      specify 'success' do
        expect {
          post :create, profile: valid_params
        }.to change(account.organization_profiles, :count).by (1)

        expect(response).to redirect_to(account_profiles_path)
      end

      specify 'failure' do
        expect {
          post :create, profile: valid_params.merge(name: '')
        }.to change(account.organization_profiles, :count).by (0)

        expect(response).to redirect_to(new_account_profile_path(type: 'organization'))
      end
    end
  end

  describe 'PATCH update' do
    check_authorizing { patch :update, account: { profile_id: profile2.id } }

    specify 'success' do
      patch :update, account: { profile_id: profile2.id }
      expect(account.reload.profile).to eq profile2

      expect(response).to redirect_to(account_profiles_path)
    end
  end
end
