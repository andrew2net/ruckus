require 'rails_helper'

describe 'Users', :js do
  let!(:profile)   { create :candidate_profile, name: 'John Smith', premium_by_default: true }
  let!(:account)   { create :account, profile: profile }
  let!(:ownership) { create :ownership, profile: profile, account: account }

  before { visit with_subdomain(profile.domain.name) }

  specify 'subscribe' do
    within '#header' do
      submit_button = find('.join-campaign button')

      submit_button.click
      expect(page).to have_content "can't be blank"

      fill_in 'user_email', with: 'test@example.com'
      submit_button.click
      expect(page).to have_css '.submitted'

      fill_in 'user_email', with: 'test@example.com'
      submit_button.click
      expect(page).to have_content 'You are already subscribed'
      expect(page).to have_css '#user_email[value=""]'
    end
  end

  specify 'display in admin panel', :js do
    within '#header' do
      fill_in 'user_email', with: 'test@example.com'
      find('.join-campaign button').click
    end

    expect(page).to have_css '#header .submitted'

    login_as(account, scope: :account)
    visit profile_subscriptions_path

    expect(page).to have_content 'test@example.com'
  end
end
