require 'rails_helper'

describe Profile::PressReleasesController do
  let!(:profile) { create :candidate_profile }
  let!(:account) { create :account, profile: profile }
  let!(:press_release) { create :press_release, profile: profile }
  let!(:valid_press_release_attributes) do
    {
      title: 'Title',
      url:   'http://www.google.com'
    }
  end

  before { sign_in account }

  describe 'GET #new' do
    check_authorizing { get :new }

    specify 'opening the modal' do
      get :new
      expect(response).to render_template :new
    end

    specify 'loading form into opened modal' do
      xhr :get, :new, format: :js
      expect(response).to render_template :new
    end
  end

  describe 'GET #index' do
    check_authorizing { get :index }

    specify 'opening the modal' do
      get :index
      expect(response).to render_template :index
    end

    specify 'loading list into opened modal' do
      xhr :get, :index
      expect(response).to render_template :index
    end
  end

  describe 'GET #edit' do
    check_authorizing { get :edit, id: press_release.id }

    specify 'opening the modal' do
      get :edit, id: press_release.id
      expect(response).to render_template 'edit'
    end

    specify 'loading form into opened modal' do
      xhr :get, :edit, id: press_release.id
      expect(response).to render_template 'edit'
    end
  end

  describe 'POST #create' do
    check_authorizing { post :create, press_release: valid_press_release_attributes, format: :js }

    specify 'success' do
      expect_any_instance_of(MixpanelTracker).to receive(:track_event).with(:add_new_press)
      expect { post :create, press_release: valid_press_release_attributes, format: :js }
        .to change(profile.press_releases, :count).by 1

      expect(response).to render_template :show
    end

    specify 'rejecting account id' do
      expect { post :create, press_release: valid_press_release_attributes.merge(profile_id: 356), format: :js }
        .to change(profile.press_releases, :count).by 1
    end

    specify 'failure' do
      expect { post :create, press_release: valid_press_release_attributes.merge(title: ''), format: :js }
        .to change(profile.press_releases, :count).by 0

      expect(response).to render_template :create
    end
  end

  describe 'PATCH #update' do
    check_authorizing { patch :update, id: press_release.id }

    specify 'success' do
      expect_any_instance_of(MixpanelTracker).to receive(:track_event).with(:press_update)
      expect do
        patch :update, id: press_release.id,
                       press_release: valid_press_release_attributes.merge(title: 'New title'),
                       format: :js
      end.to change(profile.press_releases, :count).by 0

      expect(response).to render_template :show
      expect(press_release.reload.title).to eq 'New title'
    end

    specify 'failure' do
      expect do
        patch :update, id: press_release.id, press_release: valid_press_release_attributes.merge(title: ''), format: :js
      end.to change(profile.press_releases, :count).by 0

      expect(response).to render_template :update
    end
  end

  describe 'DELETE #destroy' do
    check_authorizing { patch :update, id: press_release.id }

    specify do
      expect { delete :destroy, id: press_release.id, format: :js }.to change(
        profile.press_releases, :count
      ).by(-1)

      expect(response).to render_template 'destroy'
    end
  end

  describe 'POST #sort' do
    let(:press_release2) { create(:press_release, position: 3, profile: profile) }
    let(:press_release3) { create(:press_release, position: 1, profile: profile) }

    check_authorizing { post :sort, ids: [], format: :js }

    it 'should sort press_releases' do
      post :sort, ids: [press_release.id.to_s, press_release2.id.to_s, press_release3.id.to_s], format: :js
      expect(PressRelease.by_position).to eq [press_release, press_release2, press_release3]

      expect(response).to render_template 'sort'
    end
  end
end
