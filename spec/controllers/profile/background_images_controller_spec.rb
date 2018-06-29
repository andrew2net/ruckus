require 'rails_helper'

describe Profile::BackgroundImagesController do
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
    let(:updater_class) { Media::ProfileUpdater::BackgroundImage }
    let(:params) do
      {
        profile: {
          background_image_medium_id:         'background_image_medium_id',
          background_image_cropping_width:    'background_image_cropping_width',
          background_image_cropping_height:   'background_image_cropping_height',
          background_image_cropping_offset_x: 'background_image_cropping_offset_x',
          background_image_cropping_offset_y: 'background_image_cropping_offset_y',
          background_image_medium:            { image: 'image' }
        }
      }
    end

    check_authorizing { patch :update, params.merge(format: :js) }

    describe 'authorized' do
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

          specify do
            expect_any_instance_of(MixpanelTracker).to receive(:add_event).with(:background_image_update)
            expect_any_instance_of(MixpanelTracker).to receive(:track)

            patch :update, params.merge(format: :js)
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
