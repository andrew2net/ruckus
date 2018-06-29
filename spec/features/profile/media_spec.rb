require 'rails_helper'

describe 'Builder' do
  let!(:account)            { create :account, profile: profile }
  let(:photo)               { create(:medium) }
  let(:hero_unit)           { create(:medium) }
  let(:media_stream_item_1) { create(:medium) }
  let(:media_stream_item_2) { create(:medium) }
  let!(:profile) do
    create :candidate_profile, photo_medium_id:     photo.id,
                               hero_unit_medium_id: hero_unit.id,
                               media:               [photo,
                                                     hero_unit,
                                                     media_stream_item_1,
                                                     media_stream_item_2]
  end

  before do
    Medium.update_positions([media_stream_item_1.id, media_stream_item_2.id])
    login_as(account, scope: :account)

    visit profile_builder_path
    within('.admin-subnav') { click_on 'Media' }
  end

  it 'should have all links & images' do
    expect(page).to have_link 'Edit', href: edit_profile_photo_path
    expect(page).to have_link 'Edit', href: edit_profile_background_image_path
    expect(page).to have_link 'Edit', href: edit_profile_hero_unit_path
    expect(page).to have_link 'Edit', href: edit_profile_media_stream_path

    expect(page).to have_selector("img[src='#{profile.photo_url(:thumb)}']")
    expect(page).to have_selector("img[src='/images/fallback/candidate_profile_background_image_thumb_default.png']")
    expect(page).to have_selector("img[src='#{profile.hero_unit_url(:thumb)}']")

    profile.media_stream_items.each do |item|
      expect(page).to have_selector("img[src='#{item.image_url(:thumb)}']")
    end
  end
end

describe 'Media stream empty link' do
  let!(:profile) { create(:candidate_profile) }
  let!(:account) { create :account, profile: profile }
  let!(:photo)   { create(:medium, profile: profile) }

  before do
    login_as(account, scope: :account)
    visit profile_builder_path
    hide_welcome_screen

    within('.admin-subnav') { click_on 'Media' }
  end

  it 'should have link to edit media stream' do
    click_on 'Edit My Media Stream', match: :first

    within '.ruckus-modal' do
      expect(page).to have_content 'Upload or choose images and video to add your photostream.'
    end
  end
end
