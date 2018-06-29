require 'rails_helper'

describe 'Dashboard' do
  let!(:domain)       { create :domain, name: 'my-subdomain' }
  let!(:profile)      { create(profile_type, profile_attrs) }
  let(:profile_attrs) { { photo_medium: picture, media: [picture], domain: domain } }
  let(:profile_type)  { :candidate_profile }
  let!(:picture)      { create(:medium) }
  let!(:account)      { create :account, profile: profile }
  let!(:de_account)   { create(:de_account, profile: profile) }
  let!(:upcoming_event) do
    create :event, profile: profile,
                   title: 'Great Event',
                   city: 'City1',
                   state: 'CO',
                   start_time: Time.parse('3 June 2015 15:42 UTC'),
                   show_start_time: true
  end
  let!(:expired_event) do
    create :event, profile: profile,
                   title: 'Too Late',
                   start_time: 2.weeks.ago
  end
  let!(:upcoming_event_without_time) do
    create :event, profile: profile,
                   title: 'Great Event',
                   city: 'City2',
                   state: 'CO',
                   start_time: Time.parse('4 June 2015 16:42 UTC'),
                   show_start_time: false
  end

  let!(:social_post) { create :social_post, profile: profile }

  before do
    12.times { profile.users.create(attributes_for(:user)) }
    4.times  { create(:donation, profile: profile, amount: 10.05) }

    login_as(account, scope: :account)
    visit profile_dashboard_path
  end

  describe 'Destroying Social Posts', :js do
    it 'should remove social post' do
      hide_welcome_screen
      find('.trash', visible: false).click
      visit profile_dashboard_path
      expect(page).to have_no_css '.trash'
    end
  end

  describe 'Org info' do
    let(:profile_type) { :organization_profile }

    specify 'links' do
      expect(page).to have_link 'Priorities', href: profile_builder_path(resources: :priorities)
    end
  end

  describe 'Candidate Info' do
    specify 'displaying subscriptions count' do
      profile.users.update_all(subscribed: true)
      visit profile_dashboard_path
      expect(page).to have_css '#subscriptoins-count', text: '12'

      profile.users.update_all(subscribed: false)
      visit profile_dashboard_path
      expect(page).to have_css '#subscriptoins-count', text: '0'
    end

    it 'shows the link to edit domain', cassette_name: 'account_dashboard' do
      expect(page).to have_link nil, href: profile_builder_path(resources: :photo)
      expect(page).to have_selector("img[src='#{profile.photo_url(:middle_thumb)}']")
      expect(page).to have_link 'my-subdomain.example.com', href: root_url(subdomain: 'my-subdomain')
      expect(page).to have_content '$40.20' #donations total
      # todo: it shows sum of all donations. mb should show only successful ones
      expect(page).to have_content profile.domain.name
      expect(page).to have_link 'Edit Domain', href: profile_domains_path
      expect(page).to have_link 'Donations Settings', href: edit_profile_page_option_path
      expect(page).to have_link 'View Subscriber List', href: profile_subscriptions_path

      # Dropdown
      expect(page).to have_link 'Issues', href: profile_builder_path(resources: :issues)
      expect(page).to have_link 'Events', href: profile_builder_path(resources: :events)
      expect(page).to have_link 'Press', href: profile_builder_path(resources: :press)
      expect(page).to have_link 'Profile Photo', href: profile_builder_path(resources: :photo)
      expect(page).to have_link 'Featured Image/Video', href: profile_builder_path(resources: :featured)
      expect(page).to have_link 'Background Image', href: profile_builder_path(resources: :background)
      expect(page).to have_link 'Photostream', href: profile_builder_path(resources: :stream)

      within '#upcoming_events' do
        expect(page).to have_link 'Manage', href: profile_builder_path(resources: :events)
      end
    end

    context '"premium" badge' do
      context 'show', :js do
        before { click_link 'Build my site' }

        let!(:profile) { create(:candidate_profile, :premium, profile_attrs) }

        specify do
          within '.dashboard-header-text' do
            expect(page).to have_content 'upgraded'
            expect(page).to have_link 'cancel'
          end
        end
      end

      context 'not show' do
        let!(:profile) { create(:candidate_profile, :free, profile_attrs) }

        specify do
          within '.dashboard-header-text' do
            expect(page).to have_no_content 'premium'
            expect(page).to have_no_link 'cancel'
          end
        end
      end
    end
  end
end
