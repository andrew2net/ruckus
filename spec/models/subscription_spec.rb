require 'rails_helper'

describe Subscription do
  describe 'associations' do
    it { expect(subject).to belong_to(:profile) }
    it { expect(subject).to belong_to(:user) }
  end

  describe '::subscribed' do
    let!(:good_subscription) { create(:subscription, user: good_user) }
    let!(:bad_subscription)  { create(:subscription, user: bad_user) }
    let!(:good_user) { create(:user, subscribed: true,  email: 'good@gmail.com') }
    let!(:bad_user)  { create(:user, subscribed: false, email: 'bad@gmail.com') }

    it 'should show subscribed/unsubscribed subscribers' do
      expect(Subscription.subscribed).to eq [good_subscription]
    end
  end
end
