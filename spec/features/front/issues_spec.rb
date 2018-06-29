require 'rails_helper'

describe 'Issue: ' do
  let!(:profile)   { create :candidate_profile, issues_on: true, premium_by_default: true }
  let!(:account)   { create :account, profile: profile }
  let!(:ownership) { create :ownership, profile: profile, account: account }
  let!(:issue1) do
    create :issue, profile:        profile,
                   title:          'really very very very very very long title',
                   description:    "Some\nText",
                   issue_category: create(:issue_category, profile: profile)
  end
  let!(:issue2) do
    create :issue, profile:        profile,
                   title:          'really very very very very very long title',
                   issue_category: create(:issue_category, profile: profile, name: 'National Security')
  end

  before { visit with_subdomain(profile.domain.name) }

  it 'should show events' do
    within "#issue-#{issue1.id}" do
      within '.slide-content' do
        expect(page).to have_css('h5', text: 'really very very ...')

        within '.slide-copy' do
          expect(page.html).to include "Some\n<br />Text"
        end
      end
    end
  end

  it 'should assign national security class' do
    expect(page).to have_css("#issue-#{issue2.id} .category-national-security")
  end

  describe 'displaying OG tags' do
    specify do
      visit front_profile_issue_path(profile, issue1)

      expect(page).to have_selector :xpath, '//head/meta[@property="fb:app_id"]', visible: false
      expect(page).to have_selector :xpath, '//head/meta[@property="og:site_name"]', visible: false
      expect(page).to have_selector :xpath, '//head/meta[@property="og:type"]', visible: false
      expect(page).to have_selector :xpath, '//head/meta[@property="og:title"]', visible: false
      expect(page).to have_selector :xpath, '//head/meta[@property="og:description"]', visible: false
      expect(page).to have_selector :xpath, '//head/meta[@property="og:url"]', visible: false
      expect(page).to have_selector :xpath, '//head/meta[@property="og:image"]', visible: false
    end
  end
end
