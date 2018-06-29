require 'rails_helper'

describe Admin::PressReleasesController do
  let(:admin)    { create :admin }
  let!(:profile) { create :candidate_profile }
  let(:account)  { create :account, profile: profile }
  let!(:press_release) { create :press_release, profile: profile, title: 'Title' }

  describe 'Actions' do
    before { sign_in admin }

    specify 'GET #index' do
      get :index, profile_id: profile.id, account_id: account.id
      expect(response).to render_template :index
    end

    specify 'GET #new' do
      get :new, profile_id: profile.id, account_id: account.id
      expect(response).to render_template :new
    end

    specify 'GET #edit' do
      get :edit, id: press_release.id, profile_id: profile.id, account_id: account.id
      expect(response).to render_template :edit
    end

    specify 'GET #show' do
      get :show, id: press_release.id, profile_id: profile.id, account_id: account.id
      expect(response).to render_template :show
    end

    specify 'DELETE #destroy' do
      delete :destroy, id: press_release.id, profile_id: profile.id, account_id: account.id

      expect(response).to redirect_to admin_account_profile_press_releases_path(account, profile)
      expect(profile.press_releases.count).to be_zero
    end

    describe 'POST #create' do
      let(:params) do
        { title: 'My Title',
          description: 'My Description',
          url: 'http://www.google.com' }
      end


      specify 'create valid press_release' do
        expect { post :create, press_release: params, profile_id: profile.id, account_id: account.id }
          .to change(profile.press_releases, :count).by(1)
        expect(response).to redirect_to admin_account_profile_press_releases_path(account, profile)
      end

      specify 'create invalid press_release' do
        params.merge!(title: '')

        expect { post :create, press_release: params, profile_id: profile.id, account_id: account.id }
          .to change(PressRelease, :count).by(0)
        expect(response).to render_template :new
      end
    end

    describe 'PATCH #update' do
      specify 'update with valid params' do
        patch :update, id: press_release.id, press_release: { title: 'New Title' }, profile_id: profile.id,  account_id: account.id

        expect(response).to redirect_to admin_account_profile_press_releases_path(account, profile)
        expect(press_release.reload.title).to eq 'New Title'
      end

      specify 'update with invalid params' do
        patch :update, id: press_release.id, press_release: { title: '' }, profile_id: profile.id, account_id: account.id

        expect(response).to render_template :edit
        expect(press_release.reload.title).to eq 'Title'
      end
    end
  end

  describe 'Access' do
    specify 'should not allow profile to enter' do
      sign_in account
      get :index, profile_id: profile.id, account_id: account.id

      expect(response).to redirect_to new_admin_session_path
    end

    specify 'should not allow anyone to enter' do
      get :index, profile_id: profile.id, account_id: account.id

      expect(response).to redirect_to new_admin_session_path
    end
  end
end
