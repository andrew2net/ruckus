require 'rails_helper'

describe MixpanelTracker do
  describe 'methods' do
    let!(:profile) do
      create(:candidate_profile, first_name:        'Carl',
                                 last_name:         'Johnson',
                                 address_1:         '84, Main st.',
                                 address_2:         '85, Main st.',
                                 contact_city:      'Los Santos',
                                 city:              'Liberty City',
                                 state:             'NY',
                                 contact_zip:       '12345',
                                 phone:             '704-232-3738',
                                 campaign_website:  'http://www.google.by',
                                 office:            'Governor',
                                 district:          'who knows',
                                 party_affiliation: 'Democrat',
                                 tagline:           'Test Slogan')
    end

    let!(:ownerships)        { create :ownership, profile: profile, account: account }
    let!(:account)           { create :account, profile: profile }
    let!(:mixpanel_tracker)  { MixpanelTracker.new(account) }

    specify '#initialize' do
      expect(mixpanel_tracker.instance_variable_get(:@account)).to eq account
      expect(mixpanel_tracker.instance_variable_get(:@profile)).to eq account.candidate_profiles.first
      expect(mixpanel_tracker.instance_variable_get(:@events)).to eq []
      expect(mixpanel_tracker.instance_variable_get(:@issue_title)).to be_nil
    end

    specify '#add_event' do
      mixpanel_tracker.add_event :some_event

      expect(mixpanel_tracker.instance_variable_get(:@events)).to include 'some_event'
    end

    specify '#track_event' do
      expect_any_instance_of(MixpanelTracker).to receive(:add_event).with :some_event
      expect_any_instance_of(MixpanelTracker).to receive(:track)

      mixpanel_tracker.track_event :some_event
    end

    describe '#track' do
      let(:properties) do
        {
          'user_id'                        => account.id,
          'user_account_type'              => 'Candidate',
          'user_admin_first_name'          => 'Carl',
          'user_admin_last_name'           => 'Johnson',
          'user_email'                     => account.email,
          'user_admin_address1'            => '84, Main st.',
          'user_admin_address2'            => '85, Main st.',
          'user_admin_city'                => 'Los Santos',
          'user_admin_state'               => 'CA',
          'user_display_city'              => 'Liberty City',
          'user_display_state'             => 'NY',
          'user_display_zip'               => '12345',
          'user_admin_phone'               => '704-232-3738',
          'user_display_url'               => 'http://www.google.by',
          'user_ruckus_url'                => 'carl-johnson',
          'user_facebook_handle'           => 'N/A',
          'user_twitter_handle'            => 'N/A',
          'account_status_deactivate_date' => '',
          'user_sign_up_date'              => account.created_at.to_s,
          'candidate_display_name'         => 'Carl Johnson',
          'candidate_office_name'          => 'Governor',
          'candidate_constituency'         => 'who knows',
          'candidate_party_affiliation'    => 'Democrat',
          'candidate_tagline'              => 'Test Slogan'
        }
      end

      specify do
        allow_any_instance_of(MixpanelTracker).to receive(:should_track?).and_return true

        mixpanel_tracker.add_event :test_event_1
        mixpanel_tracker.add_event :test_event_1
        mixpanel_tracker.add_event :test_event_2

        expect(MixpanelEventSubmitter).to receive(:perform_async).with(account.id, 'test_event_1', properties)
        expect(MixpanelEventSubmitter).to receive(:perform_async).with(account.id, 'test_event_2', properties)

        mixpanel_tracker.track
      end

      specify 'bugfix' do
        Profile.destroy_all
        allow_any_instance_of(MixpanelTracker).to receive(:should_track?).and_return true

        mixpanel_tracker.add_event :test_event_1
        mixpanel_tracker.track
      end
    end
  end

  describe 'private methods' do
    describe '#account_properties' do
      let!(:profile) { create :candidate_profile }
      let!(:account) { create :account, profile: profile }
      let!(:mixpanel_tracker) { MixpanelTracker.new(account) }

      specify do
        mixpanel_tracker.send(:account_properties).tap do |properties|
          expect(properties['user_id']).to eq account.id
          expect(properties['user_email']).to eq account.email
          expect(properties['account_status_deactivate_date']).to eq account.deleted_at.to_s
          expect(properties['user_sign_up_date']).to eq account.created_at.to_s
        end
      end
    end

    describe '#common_properties' do
      let!(:profile)          { create :candidate_profile }
      let!(:domain)           { profile.domain }
      let!(:account)          { create :account, profile: profile }
      let!(:ownerships)       { create :ownership, profile: profile, account: account }
      let!(:mixpanel_tracker) { MixpanelTracker.new(account) }
      let!(:props) { { one: :two } }

      specify do
        allow_any_instance_of(MixpanelTracker).to receive(:facebook_url).and_return 'facebook-url'
        allow_any_instance_of(MixpanelTracker).to receive(:twitter_url).and_return 'twitter-url'
        allow_any_instance_of(MixpanelTracker).to receive(:account_properties).and_return props

        mixpanel_tracker.send(:common_properties).tap do |properties|
          expect(properties['user_admin_first_name']).to eq 'Bob'
          expect(properties['user_admin_last_name']).to eq 'Sinclar'
          expect(properties['user_admin_address1']).to eq '84, Main st.'
          expect(properties['user_admin_address2']).to eq '85, Main st.'
          expect(properties['user_admin_city']).to eq 'Los Angeles'
          expect(properties['user_admin_state']).to eq 'CA'
          expect(properties['user_display_city']).to eq 'Los Angeles'
          expect(properties['user_display_state']).to eq 'CA'
          expect(properties['user_display_zip']).to eq '12345'
          expect(properties['user_admin_phone']).to eq '730-233-3238'
          expect(properties['user_display_url']).to eq 'http://www.google.com'
          expect(properties['user_ruckus_url']).to eq profile.domain.name
          expect(properties['user_facebook_handle']).to eq 'facebook-url'
          expect(properties['user_twitter_handle']).to eq 'twitter-url'
          expect(properties['user_account_type']).to eq 'Candidate'
          expect(properties[:one]).to eq :two
        end
      end
    end

    describe '#organization_properties' do
      let!(:ownerships)       { create :ownership, profile: profile, account: account }
      let!(:account)          { create :account, profile: profile }
      let!(:profile)          { create(:organization_profile) }
      let!(:mixpanel_tracker) { MixpanelTracker.new(account) }
      let!(:props) { { one: :two } }

      specify do
        allow_any_instance_of(MixpanelTracker).to receive(:common_properties).and_return props
        mixpanel_tracker.send(:organization_properties).tap do |properties|
          expect(properties[:one]).to eq :two
          expect(properties['org_display_name']).to eq 'Organization Name'
          expect(properties['org_tagline']).to eq 'Test Slogan'
        end
      end
    end

    describe '#candidate_properties' do
      let!(:ownerships)       { create :ownership, profile: profile, account: account }
      let!(:account)          { create :account, profile: profile }
      let!(:profile)          { create(:candidate_profile) }
      let!(:mixpanel_tracker) { MixpanelTracker.new(account) }
      let!(:props)            { { one: :two } }

      specify do
        allow_any_instance_of(MixpanelTracker).to receive(:common_properties).and_return props
        mixpanel_tracker.send(:candidate_properties).tap do |properties|
          expect(properties[:one]).to eq :two
          expect(properties['candidate_display_name']).to eq 'Bob Sinclar'
          expect(properties['candidate_office_name']).to eq 'Governor'
          expect(properties['candidate_constituency']).to eq 'who knows'
          expect(properties['candidate_party_affiliation']).to eq 'Democrat'
          expect(properties['candidate_tagline']).to eq 'Test Slogan'
        end
      end
    end
  end
end
