require 'rails_helper'

describe 'Events switch' do
  let!(:account)   { create :account, profile: profile }
  let!(:ownership) { create :ownership, profile: profile, account: account }

  before { login_as(account, scope: :account) }

  describe 'enable/disable', :js do
    describe 'enable' do
      let!(:profile) { create :candidate_profile, events_on: false, premium_by_default: true }
      let!(:event)   { create :event, profile: profile }

      it { enables_the_block('#events-switch', '#events') }
    end

    describe 'disable' do
      let!(:profile) { create :candidate_profile, events_on: true }
      let!(:event)   { create :event, profile: profile }

      it { disables_the_block('#events-switch', '#events') }
    end
  end

  describe 'hide' do
    let!(:profile) { create :candidate_profile }

    specify do
      visit profile_builder_path
      expect(page).to have_no_css '#events-switch'
    end
  end
end
