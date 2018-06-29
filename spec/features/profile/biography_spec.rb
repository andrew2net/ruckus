require 'rails_helper'

describe 'Builder' do
  let(:profile) { create(:candidate_profile) }
  let(:account) { create :account, profile: profile }

  before do
    login_as(account, scope: :account)
    visit profile_builder_path
  end

  specify 'Edit', :js do
    profile.update(biography: nil, biography_on: true)
    visit profile_builder_path
    hide_welcome_screen

    expect(page).to have_content 'ADD BIOGRAPHY'

    within('.admin-subnav') { click_on 'Biography' }

    expect(page).to have_css '.ruckus-modal'
    expect(page).to have_content 'Share your story with a brief biography.'

    fill_in 'About Me', with: 'Lorem Ipsum'
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
      expect(page).to have_link 'Biography', href: edit_profile_biography_path
    end

    within '#about-tabs' do
      expect(page).to have_link nil, href: edit_profile_biography_path
    end
  end
end
