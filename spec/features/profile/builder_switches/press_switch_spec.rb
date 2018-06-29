require 'rails_helper'

describe 'Press switch' do
  let!(:account)   { create :account, profile: profile }
  let!(:ownership) { create :ownership, profile: profile, account: account }

  before { login_as(account, scope: :account) }

  describe 'enable/disable', :js do
    describe 'enable' do
      let!(:profile)       { create :candidate_profile, press_on: false, premium_by_default: true }
      let!(:press_release) { create :press_release, profile: profile }

      it { enables_the_block('#press-switch', '#press') }
    end

    describe 'disable' do
      let!(:profile)       { create :candidate_profile, press_on: true }
      let!(:press_release) { create :press_release, profile: profile }

      it { disables_the_block('#press-switch', '#press') }
    end
  end

  describe 'hide' do
    let!(:profile) { create :candidate_profile }

    it 'is invisible when there are no press releases' do
      visit profile_builder_path

      expect(page).to have_no_css '#press-switch'
    end
  end
end
