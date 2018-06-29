require 'rails_helper'

describe Profile::PageOptionsController do
  let(:profile) { create :candidate_profile }
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
      account.profile do |profile|
        expect(profile.register_to_vote_on).to be_falsey
        expect(profile.donations_on).to        be_truthy
        expect(profile.press_on).to            be_truthy
        expect(profile.events_on).to           be_truthy
        expect(profile.questions_on).to        be_truthy
        expect(profile.social_feed_on).to      be_truthy
      end

      patch :update, profile: {
        register_to_vote_on: true,
        donations_on:        false,
        press_on:            false,
        events_on:           false,
        questions_on:        false,
        social_feed_on:      false
      }

      account.profile.reload do |profile|
        expect(profile.register_to_vote_on).to be_truthy
        expect(profile.donations_on).to        be_falsey
        expect(profile.press_on).to            be_falsey
        expect(profile.events_on).to           be_falsey
        expect(profile.questions_on).to        be_falsey
        expect(profile.social_feed_on).to      be_falsey
      end
    end

    describe 'mixpanel' do
      specify 'donations_on' do
        expect_any_instance_of(MixpanelTracker).to receive(:add_event).with(:disable_donation_success)
        expect_any_instance_of(MixpanelTracker).to receive(:track)

        patch :update, profile: { donations_on: false }
      end

      specify 'donations_on' do
        account.profile.update donations_on: false

        expect_any_instance_of(MixpanelTracker).to receive(:add_event).with(:enable_donation_success)
        expect_any_instance_of(MixpanelTracker).to receive(:track)

        patch :update, profile: { donations_on: true }
      end

      specify 'biography_on' do
        expect_any_instance_of(MixpanelTracker).to receive(:add_event).with(:display_settings_update)
        expect_any_instance_of(MixpanelTracker).to receive(:track)

        patch :update, profile: { biography_on: true }
      end

      specify 'questions_on' do
        expect_any_instance_of(MixpanelTracker).to receive(:add_event).with(:display_settings_update)
        expect_any_instance_of(MixpanelTracker).to receive(:track)

        patch :update, profile: { questions_on: true }
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
    end
  end
end
