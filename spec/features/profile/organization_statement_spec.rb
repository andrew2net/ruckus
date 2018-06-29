require 'rails_helper'

describe 'Builder' do
  let(:profile) { create :organization_profile }
  let(:account) { create :account, profile: profile }

  before do
    login_as(account, scope: :account)
    visit profile_builder_path
  end

  specify 'Edit', :js do
    hide_welcome_screen
    account.profile.update(biography: nil, biography_on: true)
    visit profile_builder_path

    expect(page).to have_content 'ADD ORGANIZATION STATEMENT'

    click_on 'Who We Are', match: :prefer_exact

    expect(page).to have_css '.ruckus-modal'

    fill_in 'About Us', with: 'Lorem Ipsum'
    scroll_modal_to '.submit'
    click_on 'Update'

    expect(page).not_to have_content 'UPDATE'

    within '#profile-about' do
      expect(page).to have_content 'Lorem Ipsum'
    end

    expect(page).to have_css '#biography-switch'
  end

  it 'displays link' do
    within '.admin-subnav' do
      expect(page).to have_link 'Who We Are', href: edit_profile_biography_path
    end

    within '#about-tabs' do
      expect(page).to have_link nil, href: edit_profile_biography_path
    end
  end
end
