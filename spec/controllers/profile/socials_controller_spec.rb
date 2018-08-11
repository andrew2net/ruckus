require 'rails_helper'

describe Profile::SocialsController do
  let(:profile) { create :candidate_profile, facebook_on: false, twitter_on: false }
  let(:account) { create :account, profile: profile }

  before { sign_in account }

  specify 'PATCH update' do
    oauth_account = create :oauth_account, :facebook, profile: profile
    cp = create :campaing_page, oauth_account: oauth_account
    patch :update, profile: { facebook_on: true, twitter_on: true },
                   oauth_account: {
                    campaing_pages_attributes: { '0' => { id: cp.id, publishing_on: '1' } }
                   }

    account.profile.reload.tap do |profile|
      expect(profile.facebook_on).to be_truthy
      expect(profile.twitter_on).to be_truthy
    end
    expect(response).to redirect_to profile_oauth_accounts_path
  end

  describe 'mixpanel' do
    specify 'facebook_on' do
      oauth_account = create :oauth_account, :facebook, profile: profile
      cp = create :campaing_page, oauth_account: oauth_account
      expect_any_instance_of(MixpanelTracker).to receive(:add_event).with(:edit_facebook)
      expect_any_instance_of(MixpanelTracker).to receive(:track)
      patch :update, profile: { facebook_on: true }, oauth_account: {
        campaing_pages_attributes: { '0' => { id: cp.id, publishing_on: '1' } }
      }
    end

    specify 'twitter_on' do
      expect_any_instance_of(MixpanelTracker).to receive(:add_event).with(:edit_twitter)
      expect_any_instance_of(MixpanelTracker).to receive(:track)
      patch :update, profile: { twitter_on: true }
    end
  end
end
