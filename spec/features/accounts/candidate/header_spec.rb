require 'rails_helper'

describe "Account's page / Header" do
  let(:account)    { create :account, profile: profile }
  let!(:ownership) { create :ownership, profile: profile, account: account }
  let!(:photo)     { File.open(Rails.root.join('spec', 'fixtures', 'photo.jpg')) }
  let!(:profile) do
    create :candidate_profile, photo:        photo,
                               tagline:      'Vote for us!',
                               donations_on: donations_on,
                               facebook_on:  true,
                               press_on:     true,
                               twitter_on:   true,
                               name:         'Will Ferrel',
                               premium_by_default: true
  end
  let!(:de_account)       { create :de_account, profile: profile, is_active_on_de: true }
  let!(:state_name)       { US_STATES_HASH[profile.state] }
  let!(:twitter_account)  { create :oauth_account, provider: 'twitter', profile: profile }
  let!(:facebook_account) { create :oauth_account, provider: 'facebook', profile: profile }
  let!(:social_post_1) do
    create :social_post, profile: profile,
                         created_at: 2.hours.ago,
                         message: 'Aut enim repellat sint.'
  end

  let!(:social_post_2) do
    create :social_post, profile: profile,
                         created_at: 4.hours.ago,
                         message: 'Distinctio dolor consequatur nostrum.'
  end
  let(:donations_on) { true }

  before { visit with_subdomain(profile.domain.name) }

  it 'should have background image' do
    beckground_img_el = find('#header-bg')
    background_img_style = "background-image:url(#{profile.background_image_url})"

    expect(beckground_img_el['style']).to have_content background_img_style
  end

  it 'should have profile info' do
    within '#account-header' do
      expect(page).to have_content 'Will Ferrel for Governor Democrat•who knows•Los Angeles, CA'
    end
  end

  describe 'should have Social Feed panel' do
    specify do
      within '#social-feed' do
        expect(page).to have_css "img[src*='#{ profile.photo_url(:small_thumb) }']"
        expect(page).to have_content 'Will Ferrel'
        expect(page).to have_content '2 hours ago'
        expect(page).to have_content 'Aut enim repellat sint.'
        expect(page).to have_css '.icon-heart'

        expect(page).to have_no_content '4 hours ago'
        expect(page).to have_no_content 'Distinctio dolor consequatur nostrum.'
      end
    end
  end

  it 'should have no social post box when there are no posts' do
    SocialPost.destroy_all
    visit with_subdomain(profile.domain.name)
    expect(page).to have_no_css '#social-feed'
  end

  it 'should have donate button' do
    expect(page).to have_link('Donate', href: new_front_profile_donation_path(profile))
  end

  describe 'hide donation button' do
    let(:donations_on) { false }

    specify do
      visit with_subdomain(profile.domain.name)
      expect(page).not_to have_link('Donate', href: new_front_profile_donation_path(profile))
    end
  end

  describe 'profile image' do
    let(:fallback_url) { "/images/fallback/candidate_profile_photo_thumb_default.png" }

    it 'should be visible' do
      expect(page).to have_selector("img[alt='#{profile.name}'][src*='#{profile.photo_url(:thumb)}']")
      expect(page).to have_no_selector("img[alt='#{profile.name}'][src*='#{fallback_url}']")
    end

    context do
      let!(:second_profile)   { create :candidate_profile, photo: nil }
      let(:account)           { create :account, profile: second_profile }
      let!(:second_ownership) { create :ownership, profile: second_profile, account: account }

      before { visit with_subdomain(second_profile.domain.name) }

      it 'should be default' do
        expect(page).to have_no_selector("img[alt='#{second_profile.name}']")
      end
    end
  end

  context 'join campaign panel' do
    it 'should have title' do
      within '#join-campaign-head' do
        expect(page).to have_content 'Vote for us!'
      end
    end

    describe 'social buttons' do
      context do
        before do
          profile.oauth_accounts.destroy_all
          visit current_url
        end

        it 'should be hidden' do
          within '#join-campaign-head' do
            expect(page).not_to have_css '.facebook'
            expect(page).not_to have_css '.twitter'
          end
        end
      end

      it 'should be visible' do
        within '#join-campaign-head' do
          expect(page).to have_css '.facebook'
          expect(page).to have_css '.twitter'
        end
      end
    end
  end

  describe 'press_releases' do
    it('should be hidden') { expect(page).not_to have_css '#press_releases' }

    describe do
      let!(:press_release1) { create(:press_release, profile: account.profile) }

      before { visit current_url }

      it 'should be visible' do
        within '#press' do
          expect(page).to have_link(press_release1.title, href: press_release1.url)
        end
      end
    end
  end
end
