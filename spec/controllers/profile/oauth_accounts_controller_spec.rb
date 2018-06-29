require 'rails_helper'

describe Profile::OauthAccountsController do
  let(:profile) { create :candidate_profile }
  let(:account) { create :account, profile: profile }

  before { sign_in account }

  describe 'GET #index' do
    specify 'success' do
      get :index
      expect(response).to render_template :index
    end
  end

  describe 'DELETE #destroy' do
    let(:twitter_account) { create :oauth_account, profile: profile, provider: 'twitter' }
    let(:facebook_account) { create :oauth_account, profile: profile, provider: 'facebook' }

    after do
      expect(response).to redirect_to profile_oauth_accounts_path
      expect(profile.oauth_accounts.count).to eq 1
    end

    specify 'Twitter' do
      expect_any_instance_of(MixpanelTracker).to receive(:add_event).with(:deactivate_twitter)
      expect_any_instance_of(MixpanelTracker).to receive(:track)
      delete :destroy, id: twitter_account.id
      expect(flash[:notice]).to start_with 'Your Twitter account was successfully unlinked'
      expect(twitter_account.reload).to be_inactive
    end

    specify 'Facebook' do
      expect_any_instance_of(MixpanelTracker).to receive(:add_event).with(:deactivate_facebook)
      expect_any_instance_of(MixpanelTracker).to receive(:track)
      delete :destroy, id: facebook_account.id
      expect(flash[:notice]).to start_with 'Your Facebook account was successfully unlinked'
      expect(facebook_account.reload).to be_inactive
    end
  end
end
