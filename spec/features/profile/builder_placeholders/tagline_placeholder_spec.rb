require 'rails_helper'

describe 'Tagline Placeholder' do
  let!(:account) { create :account }

  before { login_as(account, scope: :account) }

  describe 'showing photo' do
    let!(:profile) { create :candidate_profile, account: account, tagline: 'great tagline' }

    specify do
      visit profile_builder_path

      expect(page).to have_text 'great tagline'
      expect(page).to have_no_css '.text-placeholder', text: 'Tagline'
    end
  end

  describe 'show placeholder' do
    let!(:profile) { create :candidate_profile, account: account, tagline: nil }

    specify do
      visit profile_builder_path

      expect(page).to have_css '.text-placeholder', text: 'Tagline'
    end
  end
end
