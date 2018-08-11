require 'rails_helper'

describe 'Settings', :js do
  let!(:profile) { create :candidate_profile, twitter_on: false, facebook_on: false }
  let!(:account) { create :account, profile: profile }

  before do
    login_as(account, scope: :account)
    visit profile_oauth_accounts_path
  end

  describe 'Connect Account' do
    specify 'Twitter' do
      expect(page).to have_no_css 'a.active', text: 'Twitter'
      expect(page).to have_css 'a', text: 'Twitter'
      click_on 'Build my site'
      expect { click_on 'Twitter' }.to change(OauthAccount, :count).by(1)
      expect(page).to have_css 'a.active', text: 'Twitter'

      within '.twitter-button-group' do
        click_on 'Twitter'
        expect(page).to have_checked_field 'Show Like and Share Button'
        find('[for="profile_twitter_on"]').click
        click_on 'SAVE'
      end

      expect(page).to have_content 'CANDIDATE PROFILE WAS SUCCESSFULLY UPDATED.'
      expect(page).to have_no_checked_field 'Show Like and Share Button'

      visit profile_oauth_accounts_path

      within '.twitter-button-group' do
        click_on 'Twitter'
        expect(page).not_to have_css '.checkbox.active'
        find('[for="profile_twitter_on"]').click
        expect(page).to have_css '.checkbox.active'
        click_on 'Cancel'
        expect(page).not_to have_link 'Cancel'
        click_on 'Twitter'
        expect(page).not_to have_css '.checkbox.active'
      end
    end

    specify 'Facebook', stub_koala: 2 do
      allow_any_instance_of(Medium).to receive(:remote_image_url)
      expect(page).to have_no_css 'a.active', text: 'Facebook'
      expect(page).to have_css 'a', text: 'Facebook'
      click_on 'Build my site'
      expect { click_on 'Facebook' }.to change(OauthAccount, :count).by(1)
      expect(page).to have_css 'a.active', 'Facebook'

      within '.facebook-button-group' do
        click_on 'Facebook'
        expect(page).to have_checked_field 'Show Like and Share Button'
        find('[for="profile_facebook_on"]').click
        click_on 'SAVE'
      end

      expect(page).to have_content 'CANDIDATE PROFILE WAS SUCCESSFULLY UPDATED.'
      expect(page).to have_no_checked_field 'Show Like and Share Button'

      visit profile_oauth_accounts_path

      within '.facebook-button-group' do
        click_on 'Facebook'
        expect(page).not_to have_css '.checkbox.active'
        find('[for="profile_facebook_on"]').click
        expect(page).to have_css '.checkbox.active'
        click_on 'Cancel'
        expect(page).not_to have_link 'Cancel'
        click_on 'Facebook'
        expect(page).not_to have_css '.checkbox.active'
      end
    end
  end
end
