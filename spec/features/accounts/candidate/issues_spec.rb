require 'rails_helper'

describe "Account's page / Issues" do
  let(:issues_on)  { true }
  let(:profile)    { create :candidate_profile, issues_on: issues_on, premium_by_default: true }
  let(:account)    { create :account, profile: profile }
  let!(:ownership) { create :ownership, profile: profile, account: account }
  let!(:issue1) { create(:issue, description: "Some\nText", issue_category: create(:issue_category, profile: profile, created_at: Time.now + 2.day)) }
  let!(:issue2) { create(:issue, description: "Some\nText", issue_category: create(:issue_category, profile: profile)) }
  let!(:issue3) { create(:issue, description: "Some\nText", issue_category: create(:issue_category, profile: nil, created_at: Time.now - 1.day), profile: profile) }

  let(:issue_category) { create(:issue_category) }

  before { visit with_subdomain(profile.domain.name) }

  it 'should show issues preview', :js do
    [issue1, issue2, issue3].each do |issue|
      within "#issues" do
        expect(page).to have_css('h4', text: issue.issue_category.name.upcase)
        expect(page).to have_css('.slide-inner h5', text: issue.title)

        find("#issue-#{issue.id}").click
      end

      within '.mfp-content' do
        expect(page).to have_css('h4', issue.issue_category.name.upcase)
        expect(page).to have_css('h5', issue.title)
        within '.slide-copy' do
          expect(page.html).to include "Some\n<br>Text"
        end

        find('.mfp-close').click
      end
    end
  end

  specify 'i can like on issue', :js do
    find("#issue-#{issue1.id}").click
    find('a.likes').click

    expect(page).to have_css('.icon-heart span', text: 1)
    expect(issue1.reload.scores.count).to eq 1

    find('.mfp-close').click

    expect(page).to have_css("#issue-#{issue1.id} .fa-heart span", text: 1)

    find("#issue-#{issue1.id}").click
    find('a.likes').click

    expect(page).to have_css('.icon-heart span', text: 0)
    expect(issue1.reload.scores.count).to eq 0

    find('.mfp-close').click

    expect(page).to have_css("#issue-#{issue1.id} .fa-heart span", text: 0)
  end

  context 'should hide issues' do
    let(:issues_on) { false }

    specify do
      expect(page).to have_no_selector('#issues')
    end
  end

  it 'should not show another account categories' do
    within '#issues' do
      expect(page).not_to have_link(issue_category.name)
    end
  end

  it 'should filter issue by categories', :js do
    within '#issues' do
      expect(page).to have_css('.slide-inner h5', text: issue1.title)
      expect(page).to have_css('.slide-inner h5', text: issue2.title)

      click_on issue1.issue_category.name

      expect(page).to have_css('.slide-inner h5', text: issue1.title)
      expect(page).not_to have_css('.slide-inner h5', text: issue2.title)

      click_on issue2.issue_category.name

      expect(page).not_to have_css('.slide-inner h5', text: issue1.title)
      expect(page).to have_css('.slide-inner h5', text: issue2.title)

      click_on 'All'

      expect(page).to have_css('.slide-inner h5', text: issue1.title)
      expect(page).to have_css('.slide-inner h5', text: issue2.title)
    end
  end

  specify 'check colour', :js do
    expect(page).to have_css("#issue-#{issue3.id} .category-1")
    find("#issue-#{issue3.id}").click
    expect(page).to have_css('.category-1')
    find('.mfp-close').click

    expect(page).to have_css("#issue-#{issue2.id} .category-2")
    find("#issue-#{issue2.id}").click
    expect(page).to have_css('.category-2')
    find('.mfp-close').click

    expect(page).to have_css("#issue-#{issue1.id} .category-3")
    find("#issue-#{issue1.id}").click
    expect(page).to have_css('.category-3')
    find('.mfp-close').click

    login_as(account, scope: :account)

    visit edit_profile_issue_path(issue1)

    expect(page).to have_css('.ruckus-selected .category-3')
    find('.ruckus-selected').click
    expect(page).to have_css("#issue-category-#{issue3.issue_category.id} .category-1")
    expect(page).to have_css("#issue-category-#{issue2.issue_category.id} .category-2")
    expect(page).to have_css("#issue-category-#{issue1.issue_category.id} .category-3")
  end

  specify 'should show formatted description' do
    expect(page.html).to include "Some\n<br />Text"
  end
end
