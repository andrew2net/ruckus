require 'rails_helper'

describe 'Builder', :js do
  let!(:profile) { create :candidate_profile }
  let!(:account) { create :account, profile: profile }

  let!(:image) { build(:medium, profile: profile) }
  let!(:video) do
    build(:medium, profile:         profile,
                   video_url:       VIDEOS[:vimeo][:url],
                   video_embed_url: VIDEOS[:vimeo][:embed_url])
  end

  let(:should_create_items) { false }

  before do
    login_as(account, scope: :account)

    if should_create_items
      video.save!
      image.save!
    end

    visit profile_builder_path
    hide_welcome_screen
    find('#add-photos-to-hero-unit-choice').click
  end

  describe 'hero unit selection' do
    let(:should_create_items) { true }

    specify 'video selection' do
      find("[data-id='#{video.id}']").click

      within '#hero-unit-block' do
        expect(page).to have_css "iframe[src*='#{video.video_embed_url}']"
      end
    end

    specify 'image selection & deletion' do
      find("[data-id='#{image.id}']").click

      within '#hero-unit-block' do
        expect(page).not_to have_content 'ADD FEATURED IMAGE'
        expect(page).to have_css "img[src*='#{profile.reload.hero_unit_url(:large_thumb)}']"
      end

      visit profile_builder_path(resources: :featured)

      js_click "[data-id='#{image.reload.id}'] .trash"

      expect(page).not_to have_css "[data-id='#{image.reload.id}']"
    end
  end

  describe 'media upload & selection' do
    it 'can not upload video from unnknown service' do
      fill_in 'profile_hero_unit_medium_video_url', with: 'http://thedailyshow.cc.com/videos/8x3wxa/moment-of-zen---jon-s-announcement'
      click_on 'Add Video'

      within '#hero-unit-block' do
        expect(page).not_to have_css 'iframe'
      end
    end

    it 'can upload video & auto select it' do
      fill_in 'profile_hero_unit_medium_video_url', with: VIDEOS[:vimeo][:url]
      click_on 'Add Video'

      within '#hero-unit-block' do
        expect(page).to have_css "iframe[src*='#{VIDEOS[:vimeo][:embed_url]}']"
      end
    end
  end
end
