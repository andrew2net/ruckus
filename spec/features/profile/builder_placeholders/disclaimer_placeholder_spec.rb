require 'rails_helper'

describe 'Disclaimer Placeholder' do
  let!(:account) { create :account }

  before { login_as(account, scope: :account) }

  describe 'showing photo' do
    let!(:profile) { create :candidate_profile, account: account, campaign_disclaimer: 'great disclaimer' }

    specify do
      visit profile_builder_path

      expect(page).to have_text 'great disclaimer'
      expect(page).to have_no_css '.text-placeholder', text: 'Disclaimer'
    end
  end

  describe 'show placeholder' do
    let!(:profile) { create :candidate_profile, account: account, campaign_disclaimer: nil }

    specify do
      visit profile_builder_path

      expect(page).to have_css '.text-placeholder', text: 'Disclaimer'
    end
  end
end
