require 'rails_helper'

describe "Account's page" do
  let!(:profile)   { create :candidate_profile, media_on: media_on, premium_by_default: true }
  let!(:account)   { create :account, profile: profile }
  let!(:ownership) { create :ownership, profile: profile, account: account }
  let(:media_on)   { true }

  before { visit with_subdomain(profile.domain.name) }

  describe 'media' do
    it 'should hide media section if there is no media' do
      expect(page).not_to have_css '#media.section'
    end

    context do
      let!(:medium1) { create(:medium, profile: profile, position: 1) }
      let!(:medium2) { create(:medium, profile: profile, position: 2) }

      before do
        visit current_url
      end

      describe 'should hide media section if media_on is set to false' do
        let(:media_on) { false }

        specify do
          visit with_subdomain(profile.domain.name)
          expect(page).not_to have_css '#media.section'
        end
      end

      it 'should show images' do
        within('#media.section') do
          [medium1, medium2].each do |medium|
            expect(page).to have_link(nil, href: medium.image_url)
            expect(page).to have_selector("img[src='#{medium.image_url(:large_thumb)}']")
          end
        end
      end

      it 'should have popup', :js do
        js_click("#media.section img[src='#{medium1.image_url(:large_thumb)}']")
        expect(page).to have_selector("figure img[src='#{medium1.image_url}']")
        find('.mfp-close').click
        expect(page).not_to have_selector("figure img[src='#{medium1.image_url}']")
      end

      it 'should not show div if there are no images' do
        Medium.update_all position: nil
        visit current_url

        expect(page).to have_no_selector '#media.section'
      end
    end
  end
end
