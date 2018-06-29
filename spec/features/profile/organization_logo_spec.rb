require 'rails_helper'

describe 'Builder', :js do
  let!(:profile) { create(:organization_profile) }
  let!(:account) { create :account, profile: profile }

  before { login_as(account, scope: :account) }

  describe 'photo selection' do
    let!(:medium) { create(:medium, profile_id: profile.id) }

    it 'can select logo' do
      visit profile_builder_path
      hide_welcome_screen
      find('#add-new-profile-photo-button').click
      expect(page).to have_selector('#media-upload-form')

      find('.media-block:nth-child(1)').click

      expect(page).to have_css "#header img[src*='image']"
    end
  end
end
