require 'rails_helper'

describe 'Socials' do
  # todo: move into view test
  let!(:profile)        { create :candidate_profile, facebook_on: true, twitter_on: true, premium_by_default: true }
  let!(:account)        { create :account, profile: profile }
  let!(:ownership)      { create :ownership, account: account, profile: profile }
  let!(:issue_category) { create :issue_category, profile: profile }

  describe 'Twitter' do
    context 'Account is set up' do
      let!(:twitter_account) { create :oauth_account, provider: 'twitter', profile: profile }

      describe 'Presence of all follow links' do
        after { expect(page).to have_css '.social .twitter .twitter-follow-button' }

        specify { visit with_subdomain(profile.domain.name) }
        specify { visit front_profile_social_posts_path(profile) }
        specify { visit front_profile_press_releases_path(profile) }
      end

      describe 'Presence of all tweet buttons' do
        let!(:social_post) { create :social_post, profile: profile, provider: ['twitter'] }
        let!(:issue) { create :issue, profile: profile, issue_category: issue_category }
        let!(:event) { create :event, profile: profile }

        after { expect(page).to have_css '.social a.twitter' }

        specify { visit front_profile_social_posts_path(profile) }
        specify { visit front_profile_issue_path(profile, issue, show_modal: true) }
        specify { visit front_profile_events_path(profile, event_id: event.id) }
      end

      describe 'Presence of link in footer' do
        specify do
          visit with_subdomain(profile.domain.name)
          expect(page).to have_css '.list-unstyled .twitter'
        end
      end
    end

    context 'Account is not set up' do
      describe 'Absence of follow buttons' do
        after { expect(page).to have_no_css '.social .twitter' }

        specify { visit with_subdomain(profile.domain.name) }
        specify { visit front_profile_social_posts_path(profile) }
        specify { visit front_profile_press_releases_path(profile) }
      end

      describe 'Absence of tweet buttons' do
        let!(:facebook_account) { create :oauth_account, provider: 'facebook', profile: profile }
        let!(:social_post) { create :social_post, profile: profile, provider: ['facebook'] }
        let!(:issue) { create :issue, profile: profile, issue_category: issue_category }
        let!(:event) { create :event, profile: profile }

        after { expect(page).to have_no_css '.social a.twitter' }

        specify { visit front_profile_social_posts_path(profile) }
        specify { visit front_profile_issue_path(profile, issue, show_modal: true) }
        specify { visit front_profile_events_path(profile, event_id: event.id) }
      end

      describe 'Absence of link in footer' do
        specify do
          visit with_subdomain(profile.domain.name)
          expect(page).to have_no_css '.list-unstyled .twitter'
        end
      end
    end
  end

  describe 'Facebook' do
    context 'Account is set up' do
      let!(:facebook_account) { create :oauth_account, provider: 'facebook', profile: profile }

      describe 'Presence of all follow buttons' do
        specify do
          visit front_profile_press_releases_path(profile)
          expect(page).to have_css '.social .facebook iframe'
        end
      end

      describe 'Presence of like buttons' do
        specify do
          visit with_subdomain(profile.domain.name)
          expect(page).to have_css '.social .facebook .fb-like'
        end
      end

      describe 'Presence of like iframes' do
        specify do
          visit front_profile_social_posts_path(profile)
          expect(page).to have_css '.social .facebook iframe'
        end
      end

      describe 'Presence of share buttons' do
        let!(:social_post) { create :social_post, profile: profile, provider: ['facebook'] }
        let!(:issue) { create :issue, profile: profile, issue_category: issue_category }
        let!(:event) { create :event, profile: profile }

        after { expect(page).to have_css '.social a.facebook' }

        specify { visit front_profile_social_posts_path(profile) }
        specify { visit front_profile_issue_path(profile, issue, show_modal: true) }
        specify { visit front_profile_events_path(profile, event_id: event.id) }
      end

      describe 'Presence of link in footer' do
        specify do
          visit with_subdomain(profile.domain.name)
          expect(page).to have_css '.list-unstyled .facebook'
        end
      end
    end

    context 'Account is not set up' do
      describe 'Absence of follow buttons' do
        specify do
          visit front_profile_press_releases_path(profile)
          expect(page).to have_no_css '.social .facebook'
        end
      end

      describe 'Absence of like buttons' do
        specify do
          visit with_subdomain(profile.domain.name)
          expect(page).to have_no_css '.social .facebook .fb-like'
        end
      end

      describe 'Absence of like iframes' do
        specify do
          visit front_profile_social_posts_path(profile)
          expect(page).to have_no_css '.social .facebook iframe'
        end
      end

      describe 'Absence of tweet buttons' do
        let!(:twitter_account) { create :oauth_account, provider: 'twitter', profile: profile }
        let!(:social_post) { create :social_post, profile: profile, provider: ['twitter'] }
        let!(:issue) { create :issue, profile: profile, issue_category: issue_category }
        let!(:event) { create :event, profile: profile }

        after { expect(page).to have_no_css '.social a.facebook' }

        specify { visit front_profile_social_posts_path(profile) }
        specify { visit front_profile_issue_path(profile, issue, show_modal: true) }
        specify { visit front_profile_events_path(profile, event_id: event.id) }
      end

      describe 'Absence of link in footer' do
        specify do
          visit with_subdomain(profile.domain.name)
          expect(page).to have_no_css '.list-unstyled .facebook'
        end
      end
    end
  end

  describe 'Internal liking system' do
    let!(:twitter_account) { create :oauth_account, provider: 'twitter', profile: profile }
    let!(:social_post) { create :social_post, profile: profile, provider: ['twitter'] }
    let!(:issue) { create :issue, profile: profile, issue_category: issue_category }

    after { expect(page).to have_css ".social a.likes[href='#{front_score_path}']" }

    specify { visit front_profile_social_posts_path(profile) }
    specify { visit front_profile_issue_path(profile, issue, show_modal: true) }
  end
end
