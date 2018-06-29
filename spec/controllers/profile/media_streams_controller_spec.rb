require 'rails_helper'

describe Profile::MediaStreamsController do
  let(:profile)  { create :candidate_profile }
  let!(:account) { create :account, profile: profile }

  before { sign_in(account) }

  describe 'POST #create' do
    let(:params) { { media_items: { video_url: 'video_url', images: %w(image1 image2) } } }
    let(:creator_class) { Media::Creator }

    check_authorizing { post :create, params.merge(format: :js) }

    specify do
      expect(creator_class).to(
        receive(:new).with(profile, video_url: 'video_url', images: %w(image1 image2)).and_call_original
      )
      expect_any_instance_of(creator_class).to receive(:create)

      post :create, params.merge(format: :js)

      expect(response).to render_template :show
    end
  end

  describe 'GET #edit' do
    check_authorizing { get :edit }

    specify do
      get :edit
      expect(response).to render_template :edit
    end
  end

  describe 'PATCH #update' do
    check_authorizing { patch :update, format: :js }

    context 'authorized' do
      after do
        patch :update, params.merge(format: :js)
        expect(response).to render_template :show
      end

      context 'without ids' do
        let(:params) { { profile: { media_stream_ids: [] } } }

        specify do
          expect(Medium).to_not receive(:update_positions)
          expect_any_instance_of(MixpanelTracker).to_not receive(:track_event)
        end
      end

      context 'with ids' do
        let(:params) { { profile: { media_stream_ids: [1, 2, 3] } } }

        specify do
          expect(Medium).to receive(:update_positions).with([1, 2, 3], profile_id: profile.id)
          expect_any_instance_of(MixpanelTracker).to receive(:track_event).with(:media_stream_update)
        end
      end
    end
  end

  describe 'PATCH #sort' do
    check_authorizing { patch :sort, format: :js }

    context 'authorized' do
      after { patch :sort, params.merge(format: :js) }

      context 'without ids' do
        let(:params) { { profile: { media_stream_ids: [] } } }

        specify do
          expect(Medium).to_not receive(:update_positions)
          expect_any_instance_of(MixpanelTracker).to_not receive(:track_event)
        end
      end

      context 'with ids' do
        let(:params) { { profile: { media_stream_ids: [1, 2, 3] } } }

        specify do
          expect(Medium).to receive(:update_positions).with([1, 2, 3], profile_id: profile.id)
          expect_any_instance_of(MixpanelTracker).to receive(:track_event).with(:media_stream_update)
        end
      end
    end
  end
end
