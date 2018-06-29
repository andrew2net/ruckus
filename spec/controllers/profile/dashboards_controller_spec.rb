require 'rails_helper'

describe Profile::DashboardsController do
  let!(:profile) { create(:candidate_profile) }
  let!(:account) { create :account, profile: profile }
  let!(:event) { create :event, start_time: 25.minutes.from_now, profile: profile }

  before { sign_in account }

  describe 'GET #edit' do
    specify 'success' do
      allow_any_instance_of(Profile).to receive_message_chain(:social_posts, :build).and_return 'new social post'
      allow_any_instance_of(Profile).to receive_message_chain(:social_posts, :order).and_return 'all social posts'
      allow_any_instance_of(Profile).to receive_message_chain(:sum_donations).and_return 'sum of donations'
      allow_any_instance_of(Profile).to receive_message_chain(:subscriptions, :subscribed, :count).and_return 'subscriptions count'
      allow_any_instance_of(Profile).to receive_message_chain(:events, :upcoming, :earliest_first).and_return [event]

      get :show
      expect(response).to render_template :show

      expect(assigns(:social_post)).to eq 'new social post'
      expect(assigns(:social_posts)).to eq 'all social posts'
      expect(assigns(:donations_raised)).to eq 'sum of donations'
      expect(assigns(:subscriptions_count)).to eq 'subscriptions count'
      expected_result = { event.start_time.beginning_of_month => [event] }
      expect(assigns(:events_by_month)).to eq expected_result
    end
  end
end
