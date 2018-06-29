require 'rails_helper'

describe Profile::ProfilesController do
  let(:profile) { create :candidate_profile }
  let(:account) { create :account, profile: profile }

  before { sign_in account }

  describe 'PATCH #update' do
    describe 'mixpanel' do
      specify 'donations_on' do
        expect_any_instance_of(MixpanelTracker).to receive(:add_event).with(:disable_donation_success)
        expect_any_instance_of(MixpanelTracker).to receive(:track)

        patch :update, profile: { donations_on: false }
      end

      specify 'donations_on' do
        profile.update donations_on: false

        expect_any_instance_of(MixpanelTracker).to receive(:add_event).with(:enable_donation_success)
        expect_any_instance_of(MixpanelTracker).to receive(:track)

        patch :update, profile: { donations_on: true }
      end

      specify 'biography_on' do
        expect_any_instance_of(MixpanelTracker).to receive(:add_event).with(:display_settings_update)
        expect_any_instance_of(MixpanelTracker).to receive(:track)

        patch :update, profile: { biography_on: true }
      end

      specify 'events_on' do
        expect_any_instance_of(MixpanelTracker).to receive(:add_event).with(:display_settings_update)
        expect_any_instance_of(MixpanelTracker).to receive(:track)

        patch :update, profile: { events_on: true }
      end

      specify 'press_on' do
        expect_any_instance_of(MixpanelTracker).to receive(:add_event).with(:display_settings_update)
        expect_any_instance_of(MixpanelTracker).to receive(:track)

        patch :update, profile: { press_on: true }
      end

      specify 'social_feed_on' do
        expect_any_instance_of(MixpanelTracker).to receive(:add_event).with(:display_settings_update)
        expect_any_instance_of(MixpanelTracker).to receive(:track)

        patch :update, profile: { social_feed_on: true }
      end

      specify 'issues_on' do
        expect_any_instance_of(MixpanelTracker).to receive(:add_event).with(:display_settings_update)
        expect_any_instance_of(MixpanelTracker).to receive(:track)

        patch :update, profile: { issues_on: true }
      end

      specify 'media_on' do
        expect_any_instance_of(MixpanelTracker).to receive(:add_event).with(:display_settings_update)
        expect_any_instance_of(MixpanelTracker).to receive(:track)

        patch :update, profile: { media_on: true }
      end

      specify 'hero_unit_on' do
        expect_any_instance_of(MixpanelTracker).to receive(:add_event).with(:display_settings_update)
        expect_any_instance_of(MixpanelTracker).to receive(:track)

        patch :update, profile: { hero_unit_on: true }
      end

      specify 'questions_on' do
        expect_any_instance_of(MixpanelTracker).to receive(:add_event).with(:display_settings_update)
        expect_any_instance_of(MixpanelTracker).to receive(:track)

        patch :update, profile: { questions_on: true }
      end
    end
  end
end
