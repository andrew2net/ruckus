require 'rails_helper'

describe Front::ScoresController do
  describe 'POST create' do
    let!(:issue) { create(:issue) }
    let!(:event) { create(:event) }
    let!(:social_post) { create(:social_post) }
    let!(:events) do
      {
        issue => :visitor_issue_upvote,
        event => :visitor_event_upvote,
        social_post => :visitor_campaign_update_post_upvote
      }
    end

    describe 'success' do
      after do
        expect {
          post :create, scorable_id: @resource.id, scorable_type: @resource.class.name
        }.to change(Score, :count).by(1)

        expect(@resource.reload.scores.count).to eq 1
        expect(response.status).to eq 200

        expect {
          post :create, scorable_id: @resource.id, scorable_type: @resource.class.name
        }.to change(Score, :count).by(-1)

        expect(@resource.reload.scores.count).to eq 0
        expect(response.status).to eq 204
      end

      specify 'issue' do
        expect_any_instance_of(MixpanelTracker).to receive(:track_event).with(events[issue])
        @resource = issue
      end

      specify 'event' do
        expect_any_instance_of(MixpanelTracker).to receive(:track_event).with(events[event])
        @resource = event
      end

      specify 'social_post' do
        expect_any_instance_of(MixpanelTracker).to receive(:track_event).with(events[social_post])
        @resource = social_post
      end
    end

    specify 'failure' do
      expect {
        post :create
      }.to change(Score, :count).by(0)

      expect(response.status).to eq 422
    end
  end
end
