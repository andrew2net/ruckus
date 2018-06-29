require 'rails_helper'

describe Profile::BiographiesController do
  let(:profile) { create :candidate_profile }
  let(:account) { create :account, profile: profile }

  before { sign_in account }

  describe 'PATCH #update' do
    it 'can update' do
      patch :update, profile: { biography: 'Joe Peshi' }, format: :js
      expect(account.profile.reload.biography).to eq 'Joe Peshi'
      expect(response).to render_template :show
    end

    describe 'mixpanel' do
      context 'candidate' do
        specify do
          expect_any_instance_of(MixpanelTracker).to receive(:add_event).with(:biography_update)
          expect_any_instance_of(MixpanelTracker).to receive(:track)
          patch :update, profile: { biography: 'New Bio' }, format: :js
        end
      end

      context 'organization' do
        let(:profile) { create :organization_profile }

        specify do
          expect_any_instance_of(MixpanelTracker).to receive(:add_event).with(:org_bio_update)
          expect_any_instance_of(MixpanelTracker).to receive(:track)
          patch :update, profile: { biography: 'New Bio' }, format: :js
        end
      end
    end
  end
end
