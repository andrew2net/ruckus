require 'rails_helper'

describe 'Admin::Account::PressReleases' do
  let!(:admin)   { create :admin }
  let!(:profile) { create :candidate_profile }
  let!(:account) { create :account, profile: profile }
  let!(:press_release1) do
    create :press_release, profile: profile,
                           title: 'NFHTQVXS',
                           url: 'http://hackett.biz/oswald_daugherty',
                           page_date: 'NXZZGQMT',
                           page_date_enabled: false,
                           page_thumbnail_enabled: true,
                           page_title: 'QPBQHNYM',
                           page_title_enabled: true,
                           created_at: Time.parse('2011-11-03 14:45:04 +0200'),
                           updated_at: Time.parse('2013-05-23 14:45:04 +0300')
  end
  let!(:press_release2) do
    create :press_release, profile: profile,
                           title: 'LTGDPEMO',
                           url: 'http://johnstongrimes.name/cory_price',
                           page_date: 'TOHRRMHS',
                           page_date_enabled: false,
                           page_thumbnail_enabled: true,
                           page_title: 'XJONSWDM',
                           page_title_enabled: true,
                           updated_at: Time.parse('2011-12-06 14:45:17 +0200'),
                           created_at: Time.parse('2012-06-25 14:45:17 +0300')
  end

  before { login_as_admin(admin) }

  describe 'Index' do
    it 'should display list of press_releases' do
      visit admin_account_profile_press_releases_path(account, profile)
      expect(page).to have_content 'NFHTQVXS'
      expect(page).to have_content 'LTGDPEMO'
      expect(page).to have_link 'Show', admin_account_profile_press_release_path(account, profile, press_release1)
      expect(page).to have_link 'Show', admin_account_profile_press_release_path(account, profile, press_release2)
      expect(page).to have_link 'Edit', edit_admin_account_profile_press_release_path(account, profile, press_release1)
      expect(page).to have_link 'Edit', edit_admin_account_profile_press_release_path(account, profile, press_release2)
      expect(page).to have_link 'Destroy', admin_account_profile_press_release_path(account, profile, press_release1)
      expect(page).to have_link 'Destroy', admin_account_profile_press_release_path(account, profile, press_release2)

      expect(page).to have_link 'New', new_admin_account_profile_press_release_path(account, profile)
    end
  end

  describe 'Show' do
    it 'should show press_release data' do
      visit admin_account_profile_press_release_path(account, profile, press_release2)
      expect(page).to have_content '06/25/2012'
      expect(page).to have_content 'TOHRRMHS'
      expect(page).to have_content 'No'
      expect(page).to have_content 'Yes'
      expect(page).to have_content 'XJONSWDM'
      expect(page).to have_content 'Yes'
      expect(page).to have_content 'LTGDPEMO'
      expect(page).to have_content '12/06/2011'
      expect(page).to have_content 'http://johnstongrimes.name/cory_price'
      expect(page).to have_link 'Edit', href: edit_admin_account_profile_press_release_path(account, profile, press_release2)
      expect(page).to have_link 'Back', href: admin_account_profile_press_releases_path(account, profile)
      expect(page).to have_link 'Back to Account', href: admin_account_path(account)
    end
  end

  describe 'Create' do
    before { visit new_admin_account_profile_press_release_path(account, profile) }

    it 'should create press_release for a account' do
      fill_in 'press_release_title', with: 'Title 4'
      fill_in 'press_release_url', with: 'Title 4'
      check 'Page title enabled'
      check 'Page date enabled'
      click_on 'Add'

      expect(profile.press_releases.count).to eq 2
    end

    it 'should display navigation buttons' do
      expect(page).to have_link 'Back', href: admin_account_profile_press_releases_path(account, profile)
      expect(page).to have_link 'Back to Account', href: admin_account_profile_path(account, profile)
    end
  end

  describe 'Update' do
    before { visit edit_admin_account_profile_press_release_path(account, profile, press_release1) }

    it 'should update press_release for a account' do
      fill_in 'press_release_title', with: 'Title New'
      click_on 'Update'

      press_release1.reload.tap  do |press_release|
        expect(press_release.title).to eq 'Title New'
      end
    end

    it 'should display navigation buttons' do
      expect(page).to have_link 'Show', href: admin_account_profile_press_release_path(account, profile, press_release1)
      expect(page).to have_link 'Back', href: admin_account_profile_press_releases_path(account, profile)
      expect(page).to have_link 'Back to Account', href: admin_account_path(account)
    end
  end

  describe 'Destroy' do
    it 'should destroy records' do
      visit admin_account_profile_press_releases_path(account, profile)
      click_on 'Destroy', match: :first
      expect(profile.press_releases.count).to eq 1
    end
  end
end
