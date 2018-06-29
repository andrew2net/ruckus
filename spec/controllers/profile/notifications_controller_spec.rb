require 'rails_helper'

describe Profile::NotificationsController do
  let(:profile) { create(:candidate_profile) }
  let(:account) { create :account, profile: profile }

  before { sign_in account }

  describe 'GET #edit' do
    specify 'success' do
      get :edit
      expect(response).to render_template :edit
    end
  end

  describe 'PATCH #update' do
    it 'can update' do
      expect(profile.weekly_report_on).to be_truthy
      expect(profile.donation_notifications_on).to be_truthy

      patch :update, profile: { donation_notifications_on: true, weekly_report_on: false }

      profile.reload.tap do |profile|
        expect(profile.weekly_report_on).to be_falsey
        expect(profile.donation_notifications_on).to be_truthy
      end
    end

    describe 'mixpanel' do
      specify 'donation_notifications_on' do
        expect_any_instance_of(MixpanelTracker).to receive(:add_event).with(:notifications_settings_update)
        expect_any_instance_of(MixpanelTracker).to receive(:track)

        patch :update, profile: { donation_notifications_on: false }
      end

      specify 'weekly_report_on' do
        expect_any_instance_of(MixpanelTracker).to receive(:add_event).with(:notifications_settings_update)
        expect_any_instance_of(MixpanelTracker).to receive(:track)

        patch :update, profile: { weekly_report_on: false }
      end

      specify 'signup_notifications_on' do
        expect_any_instance_of(MixpanelTracker).to receive(:add_event).with(:notifications_settings_update)
        expect_any_instance_of(MixpanelTracker).to receive(:track)

        patch :update, profile: { signup_notifications_on: false }
      end
    end
  end
end
