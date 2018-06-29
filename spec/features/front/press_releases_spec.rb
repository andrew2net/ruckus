require 'rails_helper'

describe 'Presss: ' do
  let!(:account) { create :account }
  let!(:picture) { create(:medium) }
  let!(:profile) do
    create :candidate_profile, first_name:     'John',
                               last_name:      'Smith',
                               photo_medium_id: picture.id
  end

  let!(:press_release1) { create :press_release, profile: profile, position: 3 }
  let!(:press_release2) { create :press_release, profile: profile, position: 2 }
  let!(:press_release3) do
    create :press_release, profile: profile,
                           title: 'Press title',
                           url: 'http://oops.com',
                           page_title: 'Some title for that page',
                           page_title_enabled: page_title_enabled,
                           page_date: 'October 16, 2013',
                           page_date_enabled: page_date_enabled,
                           page_thumbnail_enabled: page_thumbnail_enabled,
                           position: 1
  end

  let!(:active_image) do
    create :press_release_image, active:    true,
                                 profile: profile,
                                 press_release_url:  press_release3.url
  end
  let(:page_title_enabled) { true }
  let(:page_date_enabled) { true }
  let(:page_thumbnail_enabled) { true }

  before { visit front_profile_press_releases_path(profile.id) }

  describe 'displays account info' do
    specify do
      within('.ruckus-modal-head-content') do
        expect(page).to have_content 'John Smith'
        expect(page).to have_selector "img[src='#{profile.photo_url(:press_modal_photo_thumb)}']"
      end
    end
  end

  describe 'displays press releasess' do
    let(:image_selector) { "img[src='/uploads_test/press_release_image/image/#{active_image.id}/thumb_image1.jpg']" }
    let(:press_title)    { 'Press title' }
    let(:press_url)      { 'http://oops.com' }
    let(:page_title)     { 'Some title for that page' }
    let(:press_date)     { 'October 16, 2013' }

    it 'should sort press_releases' do
      expect(page).to have_css "#press-release-#{press_release3.id} + #press-release-#{press_release2.id}"
      expect(page).to have_css "#press-release-#{press_release2.id} + #press-release-#{press_release1.id}"
    end

    it 'should display link' do
      within('.ruckus-modal-body-content') do
        within("#press-release-#{press_release3.id}") do
          expect(page).to have_css image_selector
          expect(page).to have_link press_title, href: press_url
          expect(page).to have_content page_title
          expect(page).to have_content press_date
        end
      end
    end

    describe 'hide page title' do
      let(:page_title_enabled) { false }
      specify do
        visit front_profile_press_releases_path(profile.id)

        within('.ruckus-modal-body-content') do
          within("#press-release-#{press_release3.id}") do
            expect(page).to have_css image_selector
            expect(page).to have_link press_title, href: press_url
            expect(page).to have_no_content page_title
            expect(page).to have_content press_date
          end
        end
      end
    end

    describe 'hide page date' do
      let(:page_date_enabled) { false }
      specify do
        visit front_profile_press_releases_path(profile.id)

        within('.ruckus-modal-body-content') do
          within("#press-release-#{press_release3.id}") do
            expect(page).to have_css image_selector
            expect(page).to have_link press_title, href: press_url
            expect(page).to have_content page_title
            expect(page).to have_no_content press_date
          end
        end
      end
    end

    describe 'hide image' do
      let(:page_thumbnail_enabled) { false }

      specify do
        visit front_profile_press_releases_path(profile.id)
        within('.ruckus-modal-body-content') do
          within("#press-release-#{press_release3.id}") do
            expect(page).to have_no_css 'img'
            expect(page).to have_link press_title, href: press_url
            expect(page).to have_content page_title
            expect(page).to have_content press_date
          end
        end
      end
    end
  end

  it 'should work if there are no press releases' do
    profile.press_releases.destroy_all
    visit front_profile_press_releases_path(profile.id)
    expect(page).to have_css('.ruckus-modal-body-content')
  end
end
