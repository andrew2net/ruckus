require 'rails_helper'

describe 'Builder', :js do
  describe 'with media' do
    let!(:profile) { create(:candidate_profile) }
    let!(:account) { create :account, profile: profile }
    let!(:medium)  { create :medium, profile_id: profile.id }
    let!(:medium2) { create :medium, profile_id: profile.id }
    let!(:medium3) { create(:medium, profile: nil) }

    before do
      profile.update background_image_medium_id: medium.id
      login_as(account, scope: :account)
      visit profile_builder_path
      click_on 'Build my site'
    end

    specify 'background image selection' do
      find('.new-background-image-icon').click
      expect(page).to have_selector('#media-upload-form')
      find(".item[data-id='#{medium.id}']").click
      click_on 'Done'

      expect(page).not_to have_button 'Done'
      expect(page).to have_css "#header-bg .item.active[style*='image1.jpg']"

      visit profile_builder_path(resources: :background)
      expect(page).to have_css "[data-id='#{medium.id}']"

      js_click "[data-id='#{medium.id}'] .trash"

      expect(page).not_to have_css "[data-id='#{medium.id}']"

      expect(page).not_to have_css "#header-bg .item.active[style*='image1.jpg']"
      expect(page).to have_css "#header-bg .item.active[style*='fallback']"
    end

    specify 'cancel selection' do
      find('.new-background-image-icon').click
      expect(page).to have_selector ".item[data-id='#{medium2.id}'] .check-box"

      find(".item[data-id='#{medium2.id}']").click
      find('.photo-crop-wrapper .button-cancel').click

      expect(page).to have_selector '#media-profile-form, .media-upload', visible: true
      expect(page).to have_selector "[data-id='#{medium.id}'] .active"
    end

    specify 'trash can presence' do
      find('.new-background-image-icon').click

      within ".item[data-id='#{medium3.id}']" do
        expect(page).not_to have_selector '.icon-trash'
      end

      within ".item[data-id='#{medium2.id}']" do
        expect(page).to have_selector '.icon-trash'
      end
    end
  end

  describe 'no media warning' do
    let(:profile) { create :candidate_profile }
    let(:account) { create :account, profile: profile }

    before do
      login_as(account, scope: :account)
      visit profile_builder_path
      click_on 'Build my site'
    end

    specify do
      find('.new-background-image-icon').click
      expect(page).to have_content 'You have no media yet...'
      expect(page).to have_no_link 'Save'
    end
  end
end
