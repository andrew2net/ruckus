require 'rails_helper'

describe 'Media switch' do
  let!(:account)   { create :account, profile: profile }
  let!(:ownership) { create :ownership, profile: profile, account: account }

  before { login_as(account, scope: :account) }

  describe 'enable/disable', :js do
    let!(:medium) { create(:medium, profile: profile) }

    before { Medium.update_positions([medium.id]) }

    describe 'enable' do
      let!(:profile) { create :candidate_profile, media_on: false, premium_by_default: true }
      it { enables_the_block('#media-stream-switch', '#media') }
    end

    describe 'disable' do
      let!(:profile) { create :candidate_profile, media_on: true }
      it { disables_the_block('#media-stream-switch', '#media') }
    end
  end

  describe 'hide' do
    let!(:profile) { create :candidate_profile }

    specify do
      visit profile_builder_path
      expect(page).to have_no_css '#media-stream-switch'
    end
  end
end
