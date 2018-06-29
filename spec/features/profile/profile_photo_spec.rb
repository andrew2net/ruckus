require 'rails_helper'

describe 'Builder' do
  let(:photo_medium) { nil }
  let!(:profile) { create :candidate_profile, photo_medium: photo_medium, questions_on: true }
  let!(:account) { create :account, profile: profile }

  before { login_as(account, scope: :account) }

  context 'media present', :js do
    let!(:medium) { create :medium, profile: profile }
    let!(:medium2) { create :medium, profile: profile }
    let!(:medium3) { create :medium, profile: profile }

    specify 'selection' do
      visit profile_dashboard_path
      click_link 'Build my site'
      find('.dashboard-header.clearfix #add-new-profile-photo-button').click

      expect(page).to have_selector('#media-upload-form')

      find("[data-id='#{medium.id}']").click
      click_on 'Done'

      expect(page).to have_css "#header img[src*='image']"
      expect(page).to have_css ".question img[src*='image']"
      expect(page).to have_css ".dropdown-menu .profile-image img[src*='image']"

      find('.mfp-close').click
      expect(page).to have_css "#question-switch.active"

      visit profile_builder_path(resources: :photo)

      expect(page).to have_css "[data-id='#{medium.id}']"

      js_click "[data-id='#{medium.id}'] .trash"

      expect(page).not_to have_css "[data-id='#{medium.id}']"

      within '#header' do
        expect(page).to have_content 'ADD PROFILE IMAGE'
      end

      find("[data-id='#{medium2.id}']").click
      click_on 'Done'

      find(".item[data-id='#{medium3.id}']").click
      find('.photo-crop-wrapper .button-cancel').click

      expect(page).to have_selector "[data-id='#{medium2.id}'] .active"
    end
  end

  context 'no media' do
    it 'shows warning if there is no media' do
      open_modal
      expect(page).to have_content 'You have no media yet...'
    end
  end
end

def open_modal
  visit profile_builder_path
  click_link 'Build my site'
  find('#add-new-profile-photo-button').click
end
