require 'rails_helper'

describe Front::UsersController do
  let(:profile)  { create :candidate_profile }
  let!(:account) { create :account, profile: profile }

  describe 'POST #create' do
    it 'with valid email' do
      allow(@controller).to receive(:account_signed_in?).and_return false
      expect_any_instance_of(MixpanelTracker).to receive(:track_event).with(:visitor_subscribe, {
        subscriber_name:  '',
        subscriber_email: 'test@gmail.com',
        subscribe_date:   Date.today
      }).twice

      expect {
        2.times do
          xhr :post, :create, user: attributes_for(:user, email: 'test@gmail.com'), profile_id: profile.id
        end
      }.to change(User, :count).by(1)

      expect(ActionMailer::Base.deliveries.count).to eq 1
      expect(profile.users.first.email).to eq 'test@gmail.com'
      expect(response).to render_template 'create'
      expect(assigns(:profile)).to eq profile
    end

    it 'with not valid email' do
      expect {
        xhr :post, :create, user: attributes_for(:user, email: nil), profile_id: profile.id
      }.to change(User, :count).by(0)

      expect(ActionMailer::Base.deliveries.count).to eq 0
      expect(response).to render_template 'create'
    end
  end
end
