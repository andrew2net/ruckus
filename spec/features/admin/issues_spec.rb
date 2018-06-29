require 'rails_helper'

describe 'Admin::Account::Issues' do
  let!(:admin)   { create :admin }
  let!(:profile) { create :candidate_profile }
  let!(:account) { create :account, profile: profile }
  let!(:issue_category) { create :issue_category, profile: profile, name: 'Healthcare' }
  let!(:issue1) do
    create :issue, profile: profile,
                   issue_category: issue_category,
                   title: 'JOMTRHAX',
                   description: 'Quia quod iure et animi.'
  end
  let!(:issue2) do
    create :issue, profile: profile,
                   issue_category: issue_category,
                   title: 'MTSGJSFE',
                   description: 'Consequatur aspernatur inventore voluptatum consequatur aut non eos et.'
  end

  before { login_as_admin(admin) }

  describe 'Index' do
    it 'should display list of issues' do
      visit admin_account_profile_issues_path(account, profile)
      expect(page).to have_content 'JOMTRHAX'
      expect(page).to have_content 'MTSGJSFE'
      expect(page).to have_link 'Show', admin_account_profile_issue_path(account, profile, issue1)
      expect(page).to have_link 'Show', admin_account_profile_issue_path(account, profile, issue2)
      expect(page).to have_link 'Edit', edit_admin_account_profile_issue_path(account, profile, issue1)
      expect(page).to have_link 'Edit', edit_admin_account_profile_issue_path(account, profile, issue2)
      expect(page).to have_link 'Destroy', admin_account_profile_issue_path(account, profile, issue1)
      expect(page).to have_link 'Destroy', admin_account_profile_issue_path(account, profile, issue2)

      expect(page).to have_link 'New', new_admin_account_profile_issue_path(account, profile)
    end
  end

  describe 'Show' do
    it 'should show issue data' do
      visit admin_account_profile_issue_path(account, profile, issue2)
      expect(page).to have_content 'Healthcare'
      expect(page).to have_content 'MTSGJSFE'
      expect(page).to have_content 'Consequatur aspernatur inventore voluptatum consequatur aut non eos et.'
      expect(page).to have_link 'Edit', href: edit_admin_account_profile_issue_path(account, profile, issue2)
      expect(page).to have_link 'Back', href: admin_account_profile_issues_path(account, profile)
      expect(page).to have_link 'Back to Account', href: admin_account_path(account)
    end
  end

  describe 'Create' do
    before { visit new_admin_account_profile_issue_path(account, profile) }

    it 'should create issue for a account' do
      fill_in 'issue_title', with: 'Title 3'
      fill_in 'issue_description', with: 'qwertyu'
      click_on 'Add'

      expect(profile.issues.count).to eq 3
    end

    it 'should display navigation buttons' do
      expect(page).to have_link 'Back', href: admin_account_profile_issues_path(account, profile)
      expect(page).to have_link 'Back to Account', href: admin_account_path(account)
    end
  end

  describe 'Update' do
    before { visit edit_admin_account_profile_issue_path(account, profile, issue1) }

    it 'should update issue for a account' do
      fill_in 'issue_title', with: 'Title New'
      fill_in 'issue_description', with: 'Boom'
      click_on 'Update'

      issue1.reload.tap  do |issue|
        expect(issue.title).to eq 'Title New'
        expect(issue.description).to eq 'Boom'
      end
    end

    it 'should display navigation buttons' do
      expect(page).to have_link 'Show', href: admin_account_profile_issue_path(account, profile, issue1)
      expect(page).to have_link 'Back', href: admin_account_profile_issues_path(account, profile)
      expect(page).to have_link 'Back to Account', href: admin_account_path(account)
    end
  end

  describe 'Destroy' do
    it 'should destroy records' do
      visit admin_account_profile_issues_path(account, profile)
      click_on 'Destroy', match: :first
      expect(profile.issues.count).to eq 1
    end
  end
end
