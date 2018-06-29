require 'rails_helper'

describe Profile::PhotosController do
  let(:profile) { create :candidate_profile }
  let(:account) { create :account, profile: profile }

  before { sign_in(account) }

  describe 'GET #edit' do
    check_authorizing { get :edit }

    specify do
      get :edit
      expect(response).to render_template :edit
    end
  end

  describe 'PATCH #update' do
    let(:updater_class) { Media::ProfileUpdater::Photo }
    let(:params) do
      {
        profile: {
          photo_medium_id:         'photo_medium_id',
          photo_cropping_width:    'photo_cropping_width',
          photo_cropping_offset_x: 'photo_cropping_offset_x',
          photo_cropping_offset_y: 'photo_cropping_offset_y',
          photo_medium:            { image: 'image' }
        }
      }
    end

    check_authorizing { patch :update, params.merge(format: :js) }

    context 'authorized' do
      before { expect(updater_class).to receive(:new).with(profile, params).and_call_original }
      after { expect(response).to render_template :update }

      specify 'expect to update profile/medium' do
        expect_any_instance_of(updater_class).to receive(:process)
        patch :update, params.merge(format: :js)
      end

      context 'mixpanel' do
        before { allow_any_instance_of(updater_class).to receive(:process).and_return(success?) }

        context 'success' do
          let(:success?) { true }

          before { expect_any_instance_of(MixpanelTracker).to receive(:track) }
          after { patch :update, params.merge(format: :js) }

          context 'candidate' do
            let(:profile) { create(:candidate_profile) }

            specify do
              expect_any_instance_of(MixpanelTracker).to receive(:add_event).with(:profile_image_update)
            end
          end

          context 'organization' do
            let(:profile) { create(:organization_profile) }
            specify { expect_any_instance_of(MixpanelTracker).to receive(:add_event).with(:logo_image_update) }
          end
        end

        context 'failure' do
          let(:success?) { false }

          specify do
            expect_any_instance_of(MixpanelTracker).to_not receive(:add_event)
            expect_any_instance_of(MixpanelTracker).to_not receive(:track)

            patch :update, params.merge(format: :js)
          end
        end
      end
    end
  end
end
