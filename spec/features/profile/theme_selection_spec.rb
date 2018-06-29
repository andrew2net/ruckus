require 'rails_helper'

describe 'Account/theme selection', :js do
  let!(:profile)   { create(:candidate_profile, theme: 'theme-red', premium_by_default: true) }
  let!(:account)   { create :account, profile: profile }
  let!(:ownership) { create :ownership, profile: profile, account: account }

  before { login_as(account, scope: :account) }

  specify do
    visit profile_builder_path
    click_on 'Build my site'

    expect(page).to have_css '.theme-color-red.active'

    first('.theme-color-blue').click
    wait_for_ajax
    expect(account.profile)

    visit profile_builder_path

    expect(page).to have_css '.theme-color-blue.active'
    expect(page).to have_no_css '.theme-color-red.active'
    expect(page).to have_css 'body.theme-blue'

    visit with_subdomain(profile.domain.name)

    expect(page).to have_css 'body.theme-blue'
  end
end
