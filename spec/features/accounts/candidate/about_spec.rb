require 'rails_helper'

describe "Account's page / About" do
  let(:profile) do
    create :candidate_profile, biography_on: true, hero_unit_on: true, biography: "Some\nText", premium_by_default: true
  end
  let!(:account) { create :account, profile: profile }
  let!(:ownership) { create :ownership, profile: profile, account: account }
  let!(:video) do
    create(:medium, profile:         profile,
                    video_url:       VIDEOS[:youtube][:url],
                    video_embed_url: VIDEOS[:youtube][:embed_url])
  end

  before { visit with_subdomain(profile.domain.name) }

  describe 'video' do
    specify 'show video if it is present' do
      profile.update_attribute :hero_unit_medium_id, video.id

      visit with_subdomain(profile.domain.name)

      within('#about-video') do
        expect(page).to have_selector("iframe[src='#{video.reload.video_embed_url}']")
      end

      within('#about') do
        expect(page).to have_selector '.col-sm-5'
        expect(page).to have_no_selector '.col-sm-12'
      end
    end

    specify 'show full width about section if there is no video' do
      within('#about') do
        expect(page).to have_no_selector '#about-video'
        expect(page).to have_no_selector '.col-sm-5'
        expect(page).to have_selector '.col-sm-12'
      end
    end
  end

  it 'should show biography' do
    within '#about' do
      expect(page.html).to include "Some\n<br />Text"
    end

    profile.update(biography_on: false)
    visit current_url
    expect(page).to have_no_selector('#about-tab-wrapper')
  end
end
