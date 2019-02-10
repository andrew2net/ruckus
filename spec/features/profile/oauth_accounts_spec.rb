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

      # OmniAuth.config.test_mode = true
      # OmniAuth.config.mock_auth[:facebook] = OmniAuth::AuthHash.new(
      #   {
      #     provider: 'facebook',
      #     uid: '123545',
      #     info: {
      #       name: 'Joe Bloggs',
      #       image: 'http://graph.facebook.com/1234567/picture?type=square'
      #     },
      #     credentials: {
      #       token: 'ABCDEF...', # OAuth 2.0 access_token, which you may wish to store
      #       expires: false # this will always be true
      #     },
      #     extra: {
      #       raw_info: {
      #         id: '1234567',
      #         name: 'Joe Bloggs'
      #       }
      #     }
      #   }
      # )
      # Rails.application.env_config["devise.mapping"] = Devise.mappings[:account] # If using Devise
      # Rails.application.env_config["omniauth.auth"] = OmniAuth.config.mock_auth[:facebook]

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

      OmniAuth.config.mock_auth[:facebook]
    end
  end
end
