require 'rails_helper'

describe Profile::SubdomainsController do
  let!(:profile) { create :candidate_profile }
  let(:account)  { create :account, profile: profile }
  let!(:domain)  { profile.domain }

  before { sign_in account }

  describe 'GET show' do
    check_authorizing { get :show }

    specify 'xhr' do
      xhr :get, :show
      expect(response).to render_template :show
    end
  end

  describe 'GET edit' do
    check_authorizing { get :edit }

    specify 'xhr' do
      xhr :get, :edit
      expect(response).to render_template :edit
    end
  end

  describe 'PATCH update' do
    check_authorizing { patch :update, domain: { name: 'new-name' } }

    specify 'success' do
      expect_any_instance_of(MixpanelTracker).to receive(:track_event).with(:ruckus_url_update)
      xhr :patch, :update, domain: { name: 'new-name' }

      expect(domain.reload.name).to eq 'new-name'
      expect(response).to render_template :show
    end

    specify 'failure' do
      xhr :patch, :update, domain: { name: 'invalid test' }

      expect(response).to render_template :edit
    end
  end
end
