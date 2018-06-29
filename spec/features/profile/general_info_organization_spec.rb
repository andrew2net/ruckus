require 'rails_helper'

describe 'General Info Organization' do
  let!(:profile) { create :organization_profile, register_to_vote_on: true }
  let!(:account) { create :account, profile: profile }
  let!(:social_post) { create :social_post, profile: profile }

  before do
    login_as(account, scope: :account)
    visit profile_builder_path
    hide_welcome_screen
  end

  describe 'Edit', :js do
    before do
      click_on 'General Info'
      expect(page).to have_css '.ruckus-modal' # wait for mCustomScrollbar to initialize

      scroll_modal_to '.submit'
      expect(page).to have_button 'Update'
    end

    it 'can edit information' do
      scroll_modal_to '#profile_name'
      fill_in 'Organization Name', with: 'Humpty Dumpty'
      fill_in 'Your Tagline', with: 'Make world a better place'
      fill_in 'City', with: 'Denver'
      select 'Colorado', from: 'State', match: :first

      scroll_modal_to '#profile_campaign_website'
      fill_in 'Address', with: 'Awesome street 1', match: :prefer_exact
      fill_in 'Address Cont.', with: 'More specific address'
      fill_in 'Phone', with: '131-212-1341'
      fill_in 'profile_contact_city', with: 'Austin'
      select 'Texas', from: 'profile_contact_state'
      fill_in 'Organization URL', with: 'http://www.google.com'
      fill_in 'Disclaimer', with: 'Sponsor Info'

      click_on 'Update'

      expect(page).to have_no_content 'UPDATE'
      expect(page).to have_no_content 'PLEASE WAIT...'

      expect(page).to have_content 'Humpty Dumpty'
      expect(page).to have_content 'CO'
      expect(page).to have_content 'Awesome street 1'
      expect(page).to have_content 'More specific address'
      expect(page).to have_content '131-212-1341'

      within '#social-footer' do
        expect(page).to have_content 'Austin'
        expect(page).to have_content 'TX'
      end
    end

    it 'displays errors' do
      scroll_modal_to '#profile_campaign_website'
      fill_in 'Organization URL', with: 'something bad'

      scroll_modal_to '.submit'
      click_on 'Update'

      scroll_modal_to '#profile_campaign_website'
      expect(page).to have_content 'is not valid URL'
    end
  end
end
