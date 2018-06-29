require 'rails_helper'

describe "Account's page / Header" do
  let!(:account)   { create :account, profile: profile }
  let!(:ownership) { create :ownership, profile: profile, account: account }
  let!(:profile) do
    create :organization_profile, tagline:       'Vote for us!',
                                  donations_on: donations_on,
                                  facebook_on:  true,
                                  twitter_on:   true,
                                  press_on:     true,
                                  name:         'Google',
                                  office:       office,
                                  premium_by_default: true
  end
  let(:office)            { 'Googloffice' }
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

  it 'should not have artifact in title' do
    expect(page).to have_title 'Google'
  end

  it 'should have background image' do
    beckground_img_el = find('#header-bg')
    background_img_style = "background-image:url(#{profile.background_image_url})"

    expect(beckground_img_el['style']).to have_content background_img_style
  end

  describe 'profile info' do
    specify 'with office' do
      within '#account-header' do
        expect(page).to have_content 'Google Googloffice'
      end
    end

    context 'without office' do
      let(:office) { '   ' }

      specify do
        within '#account-header' do
          expect(page).to have_content 'Google'
        end
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

  describe 'should hide donation button' do
    let(:donations_on) { false }
    specify do
      visit with_subdomain(profile.domain.name)
      expect(page).not_to have_link('Donate', href: new_front_profile_donation_path(profile))
    end
  end

  context 'join campaign panel' do
    it 'should have title' do
      within '#account-header' do
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
