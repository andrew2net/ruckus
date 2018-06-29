require 'rails_helper'

describe Profile::SubscriptionsController do
  let!(:profile)     { create :candidate_profile }
  let!(:account)     { create :account, profile: profile }
  let!(:subscriber1) { profile.users.create attributes_for :user, subscribed: true }
  let!(:subscriber2) { profile.users.create attributes_for :user, subscribed: false }

  let(:csv_string)  { User.where(id: subscriber1).to_csv }

  before { sign_in account }

  describe 'GET #index' do
    specify 'success' do
      get :index
      expect(response).to render_template :index
      expect(assigns(:subscriptions)).to eq [subscriber1.subscriptions.first]
    end

    specify 'csv' do
      expect_any_instance_of(MixpanelTracker).to receive(:add_event).with(:export_subscribers_list)
      expect_any_instance_of(MixpanelTracker).to receive(:track)

      expect(@controller).to receive(:send_data).with(csv_string) do
        @controller.render nothing: true
      end

      get :index, format: :csv
    end
  end
end
