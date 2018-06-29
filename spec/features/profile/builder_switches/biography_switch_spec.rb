require 'rails_helper'

describe 'Biography switch' do
  let!(:account)   { create :account, profile: profile }
  let!(:ownership) { create :ownership, profile: profile, account: account }

  before { login_as(account, scope: :account) }

  describe 'enable/disable', :js do
    describe 'enable' do
      let!(:profile) { create :candidate_profile, biography_on: false, biography: 'text', premium_by_default: true }
      it { enables_the_block('#biography-switch', '#about-tab-wrapper') }
    end

    describe 'disable' do
      let!(:profile) { create :candidate_profile, biography_on: true, biography: 'text' }
      it { disables_the_block('#biography-switch', '#about-tab-wrapper') }
    end
  end

  describe 'hide' do
    let!(:profile) { create :candidate_profile, biography: nil }

    specify do
      visit profile_builder_path
      expect(page).to have_no_css '#biography-switch'
    end
  end
end
