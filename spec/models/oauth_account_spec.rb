require 'rails_helper'

describe OauthAccount do
  describe 'associations' do
    it { expect(subject).to belong_to :profile }
  end

  describe 'validations' do
    let!(:profile) { create :candidate_profile }
    subject { create :oauth_account, profile: profile }

    it { expect(subject).to validate_presence_of(:provider) }
    it { expect(subject).to validate_inclusion_of(:provider).in_array(%w(twitter facebook)) }

    it { expect(subject).to validate_presence_of(:uid) }
    it { expect(subject).to validate_uniqueness_of(:uid).scoped_to(:profile_id, :provider) }
    it { expect(subject).to validate_uniqueness_of(:provider).scoped_to(:profile_id) }

    it { expect(subject).to validate_presence_of(:url) }
  end

  describe '::by_provider' do
    let!(:profile) { create :candidate_profile }
    let!(:twitter)  { create :oauth_account, provider: 'twitter', profile: profile }
    let!(:facebook) { create :oauth_account, provider: 'facebook', profile: profile }

    specify do
      expect(OauthAccount.by_provider('twitter')).to  eq [twitter]
      expect(OauthAccount.by_provider('facebook')).to eq [facebook]
      expect(OauthAccount.by_provider('vk').to_a).to eq []

      OauthAccount.by_provider(%w(facebook twitter)).tap do |accounts|
        expect(accounts).to include facebook, twitter
        expect(accounts.count).to eq 2
      end
    end
  end



  describe 'State Machine' do
    let!(:profile)  { create(:candidate_profile, twitter_on: false, facebook_on: false) }
    let!(:twitter)  { create(:oauth_account, :twitter,  profile: profile) }
    let!(:facebook) { create(:oauth_account, :facebook, profile: profile) }

    specify do
      expect(twitter).to  be_active
      expect(facebook).to be_active
      expect(profile.reload.twitter_on).to  be_truthy
      expect(profile.reload.facebook_on).to be_truthy

      twitter.reload.deactivate!
      facebook.reload.deactivate!
      expect(twitter).to  be_inactive
      expect(facebook).to be_inactive
      expect(profile.twitter_on).to  be_truthy
      expect(profile.reload.facebook_on).to be_truthy

      profile.update!(twitter_on: false, facebook_on: false)
      twitter.reload.activate!
      facebook.reload.activate!
      expect(twitter).to  be_active
      expect(facebook).to be_active
      expect(profile.reload.twitter_on).to  be_truthy
      expect(profile.reload.facebook_on).to be_truthy
    end
  end

  describe 'observers' do
    describe '#show_buttons' do
      let!(:profile1) { create :candidate_profile, facebook_on: false, twitter_on: false }
      let!(:profile2) { create :candidate_profile, facebook_on: false, twitter_on: false }

      let!(:twitter)  { create(:oauth_account, provider: 'twitter', profile: profile1) }
      let!(:facebook) { create(:oauth_account, provider: 'facebook', profile: profile2) }

      it 'should enable posting for a specific account' do
        expect(profile1.twitter_on).to be_truthy
        expect(profile1.facebook_on).to be_falsey

        expect(profile2.twitter_on).to be_falsey
        expect(profile2.facebook_on).to be_truthy
      end
    end
  end
end
