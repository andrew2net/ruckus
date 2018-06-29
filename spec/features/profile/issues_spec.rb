require 'rails_helper'

describe 'Builder / Issues', :js do
  let!(:profile) { create :candidate_profile, issues_on: true }
  let!(:account) { create :account, profile: profile }
  let!(:issue_category) { create(:issue_category, profile: profile, name: 'National Security') }

  before { login_as(account, scope: :account) }

  describe 'Index' do
    let!(:issue1) { create(:issue, profile: profile, issue_category: issue_category) }
    let!(:issue2) { create(:issue, profile: profile, issue_category: issue_category) }
    let!(:issue3) { create(:issue, profile: profile, issue_category: issue_category) }

    before do
      Issue.update_positions([issue3.id, issue1.id, issue2.id])

      visit profile_builder_path
      hide_welcome_screen

      within('.admin-subnav') { click_on 'Issues' }
      expect(page).to have_css '.ruckus-modal'
    end

    specify 'issues list' do
      expect(page).to have_css "#issue-#{issue3.id} + #issue-#{issue1.id} + #issue-#{issue2.id}"

      [issue1, issue2, issue3].each do |issue|
        expect(page).to have_link(issue.title, href: edit_profile_issue_path(issue))
      end
    end

    specify 'deleting issues' do
      expect(page).to have_css "#issue-#{issue1.id} .trash"

      find("#issue-#{issue1.id} .trash").click
      expect(page).not_to have_css("#issue-#{issue1.id}")
    end
  end

  describe 'Create' do
    before do
      visit profile_builder_path
      hide_welcome_screen

      within('.admin-subnav') { click_on 'Issues' }
      click_on 'Add New Issue'
    end

    it 'should have buttons & errors' do
      expect(page).to have_button 'Add'

      submit_form_with_js('#new_issue')

      expect(page).to have_content "can't be blank", count: 3
    end

    context 'success' do
      before { allow_any_instance_of(Percent::Cell).to receive(:percent_completed).and_return(666) }

      specify do
        expect(page).to have_content 'Select an Issue Topic'
        within('.spinner') { expect(page).to have_no_content '666%' }

        page.fill_in 'issue_title', with: 'Some title'
        page.fill_in 'issue_description', with: 'Some description'
        find('.ruckus-selected').click()
        find("#issue-category-#{issue_category.id}").click
        click_on 'Add'

        within('#issues') { expect(page).to have_content 'Some title' }
        expect(page).to have_css '#issues-switch'
        within('.spinner') { expect(page).to have_content '666%' }
      end
    end
  end

  describe 'Update' do
    let!(:non_profile_category) { create(:issue_category) }
    let!(:issue) { create(:issue, profile: profile, issue_category: issue_category) }

    before do
      visit profile_builder_path
      hide_welcome_screen

      find("[href='#{edit_profile_issue_path(issue)}']").click
    end

    specify 'updating process' do
      expect(page).to have_link('Cancel', href: profile_issues_path)
      expect(page).to have_button 'Update'
      expect(page).not_to have_css("#issue-category-#{non_profile_category.id}")

      page.fill_in 'issue_title', with: 'Some new title'
      page.fill_in 'issue_description', with: 'Some new description'
      find('.ruckus-selected').click
      fill_in 'issue_category_name', with: 'New category'

      submit_form_with_js('#new_issue_category_form')

      within '.ruckus-drop .ruckus-selected' do
        expect(page).to have_content 'New category'
      end

      click_on 'Update'

      expect(page).not_to have_link 'Cancel', href: profile_issues_path

      within '#issues-slider-wrapper' do
        expect(page).to have_content 'Some new title'
        expect(page).to have_content 'Some new description'
        expect(page).to have_content 'NEW CATEGORY'
      end

      within '#issues-tab-wrapper' do
        expect(page).to have_content 'New category'
      end
    end

    specify 'select correct issue category' do
      within '.ruckus-selected' do
        expect(page).to have_content 'National Security'
        expect(page).to have_css '.category-national-security'
      end
    end
  end
end
