require 'rails_helper'

describe 'Admin::Account::Profiles' do
  let!(:admin) { create :admin }
  let!(:profile) do
    create :candidate_profile,
           biography: 'Aspernatur possimus rerum hic veritatis aperiam ipsum numquam consequatur.',
           address_1: '4597 Daphnee Corner',
           address_2: '613 Nicolas Prairie',
           campaign_disclaimer: 'OCZFKKNZ',
           campaign_organization: 'EEGOLKNI',
           campaign_organization_identifier: 'OWTBOVQO',
           campaign_website: 'OPIFYNQD',
           city: 'Orrinshire',
           contact_city: 'Johnnyberg',
           contact_state: 'AZ',
           contact_zip: '34930',
           created_at: Time.parse('2013-07-10 17:39:27 +0300'),
           district: 'IMFKNFAA',
           first_name: 'Dasia',
           last_name: 'Stracke',
           office: 'PWEEHRLG',
           party_affiliation: 'JUUZMXTT',
           phone: '138-089-3330',
           tagline: 'ZBMHITTN',
           state: 'SD',
           updated_at: Time.parse('2013-10-15 17:39:27 +0300'),
           biography_on: true,
           donation_notifications_on: false,
           donations_on: false,
           events_on: false,
           facebook_on: false,
           issues_on: false,
           media_on: true,
           press_on: true,
           questions_on: false,
           signup_notifications_on: true,
           social_feed_on: false,
           weekly_report_on: false
  end

  let!(:account)   { create :account, profile: profile }
  let!(:ownership) { create :ownership, profile: profile, account: account }

  before { login_as_admin(admin) }

  describe 'Show' do
    before { visit admin_account_profile_path(account, profile) }

    specify 'should have info' do
      expect(page).to have_content 'Aspernatur possimus rerum hic veritatis aperiam ipsum numquam consequatur.'
      expect(page).to have_content '4597 Daphnee Corner'
      expect(page).to have_content '613 Nicolas Prairie'
      expect(page).to have_content 'OCZFKKNZ'
      expect(page).to have_content 'EEGOLKNI'
      expect(page).to have_content 'OWTBOVQO'
      expect(page).to have_content 'OPIFYNQD'
      expect(page).to have_content '38'
      expect(page).to have_content 'Orrinshire'
      expect(page).to have_content 'Johnnyberg'
      expect(page).to have_content 'AZ'
      expect(page).to have_content '34930'
      expect(page).to have_content '07/10/2013'
      expect(page).to have_content 'IMFKNFAA'
      expect(page).to have_content 'Dasia'
      expect(page).to have_content 'Stracke'
      expect(page).to have_content 'PWEEHRLG'
      expect(page).to have_content 'JUUZMXTT'
      expect(page).to have_content '138-089-3330'
      expect(page).to have_content 'ZBMHITTN'
      expect(page).to have_content 'SD'
      expect(page).to have_content '10/15/2013'
      expect(page).to have_selector '#biography_on', text: 'Yes'
      expect(page).to have_selector '#donation_notifications_on', text: 'No'
      expect(page).to have_selector '#donations_on', text: 'No'
      expect(page).to have_selector '#events_on', text: 'No'
      expect(page).to have_selector '#facebook_on', text: 'No'
      expect(page).to have_selector '#issues_on', text: 'No'
      expect(page).to have_selector '#media_on', text: 'Yes'
      expect(page).to have_selector '#press_on', text: 'Yes'
      expect(page).to have_selector '#questions_on', text: 'No'
      expect(page).to have_selector '#signup_notifications_on', text: 'Yes'
      expect(page).to have_selector '#social_feed_on', text: 'No'
      expect(page).to have_selector '#twitter_on', text: 'No'
      expect(page).to have_selector '#weekly_report_on', text: 'No'

      expect(page).to have_link 'Issues', admin_account_profile_issues_path(account, profile)
      expect(page).to have_link 'Press', admin_account_profile_press_releases_path(account, profile)
    end
  end
end
