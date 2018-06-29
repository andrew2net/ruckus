require 'rails_helper'

describe 'Account::SocialPost' do
  let!(:profile) { create :candidate_profile }
  let!(:account) { create :account, profile: profile }
  let!(:oauth_account) { create :oauth_account, profile: profile }

  before do
    login_as(account, scope: :account)
    allow_any_instance_of(Percent::Cell).to receive(:percent_completed).and_return 34
    visit profile_dashboard_path
  end

  specify 'Posting messages', :js do
    hide_welcome_screen

    expect(page).to have_content '34%'

    within '.new_social_post' do
      click_on 'Update'
    end

    expect(page).to have_content "MESSAGE CAN'T BE BLANK"

    allow_any_instance_of(Percent::Cell).to receive(:percent_completed).and_return 64

    within '.new_social_post' do
      fill_in 'social_post_message', with: 'Some Text'
      check 'social_post_provider'
      click_on 'Update'
    end

    expect(page).to have_content '64%'
    expect(page).to have_content 'Some Text'
    expect(page).not_to have_selector '#social_post_provider:checked'

    visit profile_dashboard_path

    expect(page).to have_content 'Some Text'

    allow_any_instance_of(Percent::Cell).to receive(:percent_completed).and_return 44

    js_click '.trash'
    expect(page).not_to have_content 'Some Text'
    expect(page).to have_content '44%'
  end
end
