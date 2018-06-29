require 'rails_helper'

describe 'Media Stream', :js do
  let!(:profile) { create :candidate_profile, media_on: true }
  let!(:account) { create :account, profile: profile }

  let!(:medium1) { create(:medium, profile: profile, position: positions[0]) }
  let!(:medium2) { create(:medium, profile: profile) }
  let!(:medium3) { create(:medium, profile: profile, position: positions[1]) }

  let(:positions) { select_items? ? [1, 2] : [] }
  let(:select_items?) { false }

  before do
    login_as(account, scope: :account)

    visit profile_builder_path
    find('#add-photos-to-media-stream').click
  end

  it 'can upload video' do
    fill_in 'media_items_video_url', with: VIDEOS[:vimeo][:url]
    click_on 'Add Video'

    expect(page).to have_css '.image-wrapper.video'
  end

  describe 'select/unselect media' do
    before do
      find("[data-id='#{medium1.id}']").click
      find("[data-id='#{medium3.id}']").click

      scroll_modal_to '.photo-stream-actions'
      click_on 'Update', match: :first
    end

    specify 'select' do
      within '#media-block' do
        expect(page).to have_css "img[src*='#{medium1.image_url(:large_thumb)}']"
        expect(page).to have_css "img[src*='#{medium3.image_url(:large_thumb)}']"
      end
    end

    describe 'unselect' do
      let(:select_items?) { true }
      specify { expect(page).not_to have_css '#media-slider' }
    end
  end

  specify 'destroy media' do
    expect(page).to have_css '.trash', count: 3
    js_click('.icon-trash:eq(0)')
    expect(page).to have_css '.trash', count: 2

    visit profile_builder_path
    find('#add-photos-to-media-stream').click

    expect(page).to have_css '.trash', count: 2
  end
end

