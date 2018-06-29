require 'rails_helper'

describe Profile::GeneralInfosController do
  let(:profile)      { create :candidate_profile }
  let!(:account)     { create :account, profile: profile }
  let!(:social_post) { create :social_post, profile: profile }

  before { sign_in account }

  describe 'PATCH #update' do
    it 'can update' do
      patch :update, profile: { name: 'Joe Smith' }, format: :js
      expect(account.profile.reload.name).to eq 'Joe Smith'
      expect(response).to render_template :show
    end

    describe 'mixpanel' do
      context 'candidate' do
        specify 'name' do
          expect_any_instance_of(MixpanelTracker).to receive(:add_event).with(:display_name_update)
          expect_any_instance_of(MixpanelTracker).to receive(:track)
          patch :update, profile: { name: 'Some Joe' }, format: :js
        end

        specify 'tagline' do
          expect_any_instance_of(MixpanelTracker).to receive(:add_event).with(:tagline_update)
          expect_any_instance_of(MixpanelTracker).to receive(:track)
          patch :update, profile: { tagline: 'new value' }, format: :js
        end

        specify 'district' do
          expect_any_instance_of(MixpanelTracker).to receive(:add_event).with(:constituency_update)
          expect_any_instance_of(MixpanelTracker).to receive(:track)
          patch :update, profile: { district: 'New Value' }, format: :js
        end

        specify 'office' do
          expect_any_instance_of(MixpanelTracker).to receive(:add_event).with(:office_update)
          expect_any_instance_of(MixpanelTracker).to receive(:track)
          patch :update, profile: { office: 'new value' }, format: :js
        end

        specify 'party_affiliation' do
          expect_any_instance_of(MixpanelTracker).to receive(:add_event).with(:party_update)
          expect_any_instance_of(MixpanelTracker).to receive(:track)
          patch :update, profile: { party_affiliation: 'New Value' }, format: :js
        end
      end

      context 'organization' do
        let(:profile) { create :organization_profile }

        specify 'name' do
          expect_any_instance_of(MixpanelTracker).to receive(:add_event).with(:org_display_name_update)
          expect_any_instance_of(MixpanelTracker).to receive(:track)
          patch :update, profile: { name: 'Some Joe' }, format: :js
        end

        specify 'tagline' do
          expect_any_instance_of(MixpanelTracker).to receive(:add_event).with(:org_tagline_update)
          expect_any_instance_of(MixpanelTracker).to receive(:track)
          patch :update, profile: { tagline: 'new value' }, format: :js
        end
      end

      context 'both' do
        specify 'city' do
          expect_any_instance_of(MixpanelTracker).to receive(:add_event).with(:display_city_update)
          expect_any_instance_of(MixpanelTracker).to receive(:track)
          patch :update, profile: { city: 'New Value' }, format: :js
        end

        specify 'state' do
          expect_any_instance_of(MixpanelTracker).to receive(:add_event).with(:display_state_update)
          expect_any_instance_of(MixpanelTracker).to receive(:track)
          patch :update, profile: { state: 'NY' }, format: :js
        end

        specify 'address_1' do
          expect_any_instance_of(MixpanelTracker).to receive(:add_event).with(:display_address1_update)
          expect_any_instance_of(MixpanelTracker).to receive(:track)
          patch :update, profile: { address_1: 'New Value' }, format: :js
        end

        specify 'address_2' do
          expect_any_instance_of(MixpanelTracker).to receive(:add_event).with(:display_address2_update)
          expect_any_instance_of(MixpanelTracker).to receive(:track)
          patch :update, profile: { address_2: 'New Value' }, format: :js
        end

        specify 'campaign_website' do
          expect_any_instance_of(MixpanelTracker).to receive(:add_event).with(:display_url_update)
          expect_any_instance_of(MixpanelTracker).to receive(:track)
          patch :update, profile: { campaign_website: 'http://gmail.com' }, format: :js
        end

        specify 'campaign_disclaimer' do
          expect_any_instance_of(MixpanelTracker).to receive(:add_event).with(:disclaimer_update)
          expect_any_instance_of(MixpanelTracker).to receive(:track)
          patch :update, profile: { campaign_disclaimer: 'new value' }, format: :js
        end

        specify 'phone' do
          expect_any_instance_of(MixpanelTracker).to receive(:add_event).with(:display_phone_update)
          expect_any_instance_of(MixpanelTracker).to receive(:track)
          patch :update, profile: { phone: '121-121-1212' }, format: :js
        end
      end
    end

    it 'can show errors' do
      patch :update, profile: { name: '' }, format: :js
      expect(response).to render_template :update
    end
  end
end
