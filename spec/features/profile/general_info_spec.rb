require 'rails_helper'

describe 'General Info' do
  let!(:profile)     { create(:candidate_profile, register_to_vote_on: true) }
  let!(:social_post) { create :social_post, profile: profile }
  let!(:account)     { create :account, profile: profile }

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
      fill_in 'Your Name', with: 'Humpty Dumpty'
      fill_in "Office You're Running for", with: 'Governor 123'
      fill_in 'Your Tagline', with: "Make world a better place #{'a' * 300}"
      fill_in 'Party Affiliation', with: 'Independants'
      fill_in 'City', with: 'Denver'
      select 'Colorado', from: 'State', match: :first

      page.execute_script "$('#profile_district').val('Some District')"

      scroll_modal_to '#profile_campaign_website'
      fill_in 'Address', with: 'Awesome street 1', match: :prefer_exact
      fill_in 'Address Cont.', with: 'More specific address'
      fill_in 'Phone', with: '131-212-1341'
      fill_in 'profile_contact_city', with: 'Austin'
      select 'Texas', from: 'profile_contact_state'
      fill_in 'profile_contact_zip', with: '12345'
      fill_in 'Campaign URL', with: 'http://www.google.com'
      fill_in 'Disclaimer', with: 'Sponsor Info'

      click_on 'Update'

      expect(page).to have_no_content 'UPDATE'
      expect(page).to have_no_content 'PLEASE WAIT...'

      expect(page).to have_content 'Humpty Dumpty'
      expect(page).to have_content 'INDEPENDANTS'
      expect(page).to have_content 'DENVER'
      expect(page).to have_content 'CO'
      expect(page).to have_content 'SOME DISTRICT'
      expect(page).to have_content 'Awesome street 1'
      expect(page).to have_content 'More specific address'
      expect(page).to have_content '131-212-1341'
      expect(page).to have_content '12345'

      within '#social-footer' do
        expect(page).to have_content 'Austin'
        expect(page).to have_content 'TX'
      end
    end

    it 'displays errors' do
      scroll_modal_to '#profile_campaign_website'
      fill_in 'Campaign URL', with: 'something bad'

      scroll_modal_to '.submit'
      click_on 'Update'

      scroll_modal_to '#profile_campaign_website'
      expect(page).to have_content 'is not valid URL'
    end
  end

  it 'displays links' do
    within '.admin-subnav' do
      expect(page).to have_link 'General Info', href: edit_profile_general_info_path
    end

    within '#header' do
      expect(page).to have_link nil, href: edit_profile_general_info_path
    end

    within '.account-meta' do
      expect(page).to have_link nil, href: edit_profile_general_info_path
    end

    within '#social-footer' do
      expect(page).to have_link nil, href: edit_profile_general_info_path
    end

    within '.account-meta' do
      expect(page).to have_link nil, href: edit_profile_general_info_path
    end
  end
end
