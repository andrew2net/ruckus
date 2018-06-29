require 'rails_helper'

describe 'Settings' do
  let(:profile) do
    create :candidate_profile, weekly_report_on:          true,
                               donation_notifications_on: true,
                               signup_notifications_on:   true
  end
  let(:account) { create :account, profile: profile }

  before do
    login_as(account, scope: :account)
    visit edit_profile_notification_path
  end

  it "should have correct field names" do
    expect(page).to have_field('Weekly Report')
    expect(page).to have_field('Donation Notifications')
    expect(page).to have_field('Email Signups')
  end

  describe 'Edit' do
    it 'can edit information' do
      uncheck 'profile_weekly_report_on'
      uncheck 'profile_donation_notifications_on'
      uncheck 'profile_signup_notifications_on'
      click_on 'Update'

      profile.reload.tap do |profile|
        expect(profile.weekly_report_on).to          be_falsey
        expect(profile.donation_notifications_on).to be_falsey
        expect(profile.signup_notifications_on).to   be_falsey
      end
    end
  end
end
