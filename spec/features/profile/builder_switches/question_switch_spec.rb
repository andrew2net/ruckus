require 'rails_helper'

describe 'Question switch' do
  let!(:account)   { create :account, profile: profile }
  let!(:ownership) { create :ownership, profile: profile, account: account }

  before { login_as(account, scope: :account) }

  describe 'enable/disable', :js do
    describe 'enable' do
      let!(:profile) { create :candidate_profile, questions_on: false, premium_by_default: true }

      specify do
        expect(page).not_to have_selector('#footer-block #question-switch')
        enables_the_block('#question-switch', '.question')
      end
    end

    describe 'disable' do
      let!(:profile) { create :candidate_profile, questions_on: true }

      specify do
        expect(page).not_to have_selector('#footer-block #question-switch')
        disables_the_block('#question-switch', '.question')
      end
    end
  end
end
