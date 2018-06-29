require 'rails_helper'

describe 'Issues switch' do
  let(:account)    { create :account, profile: profile }
  let!(:ownership) { create :ownership, profile: profile, account: account }

  before { login_as(account, scope: :account) }

  describe 'enable/disable', :js do
    let(:profile)         { create :candidate_profile, issues_on: issues_on, premium_by_default: true }
    let!(:issue_category) { create :issue_category, profile: profile }
    let!(:issue)          { create :issue, profile: profile, issue_category: issue_category }

    describe 'enable' do
      let(:issues_on) { false }

      specify do
        visit profile_builder_path
        enables_the_block('#issues-switch', '#issues')
      end
    end

    describe 'disable' do
      let(:issues_on) { true }

      specify do
        visit profile_builder_path
        disables_the_block('#issues-switch', '#issues')
      end
    end
  end

  describe 'hide' do
    let(:profile) { create :candidate_profile }

    specify do
      visit profile_builder_path
      expect(page).to have_no_css '#issues-switch'
    end
  end
end
